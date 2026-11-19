# Illustrative skeleton. NOT applied or validated against a live project.
# Review and adapt before use. Pin provider versions for real deployments.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

variable "project_id" { type = string }
variable "region" {
  type    = string
  default = "us-central1"
}
variable "agent_image" {
  type        = string
  description = "Artifact Registry image, ideally referenced by digest"
}
variable "mcp_a_url" {
  type        = string
  description = "URL of MCP server A (deployed separately)"
}
variable "network" { type = string }
variable "subnetwork" { type = string }

provider "google" {
  project = var.project_id
  region  = var.region
}

# Dedicated identity for the agent
resource "google_service_account" "agent" {
  account_id   = "agent-sa"
  display_name = "Gemini agent runtime"
}

# Call Gemini on Vertex AI with the service account (no API key)
resource "google_project_iam_member" "agent_vertex" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent.email}"
}

resource "google_project_iam_member" "agent_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.agent.email}"
}

# Example third-party secret, accessible only by agent-sa
resource "google_secret_manager_secret" "third_party" {
  secret_id = "third-party-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "agent_secret" {
  secret_id = google_secret_manager_secret.third_party.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent.email}"
}

resource "google_cloud_run_v2_service" "agent" {
  name     = "gemini-agent"
  location = var.region
  # Only reachable via an internal load balancer, not directly from the internet
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.agent.email
    timeout         = "60s"

    scaling {
      max_instance_count = 10 # cost and DoS bound
    }

    vpc_access {
      egress = "ALL_TRAFFIC" # force outbound through the VPC for egress controls
      network_interfaces {
        network    = var.network
        subnetwork = var.subnetwork
      }
    }

    containers {
      image = var.agent_image

      env {
        name  = "MCP_A_URL"
        value = var.mcp_a_url
      }

      # Secret reference, not a plaintext value
      env {
        name = "THIRD_PARTY_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.third_party.secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

# Allow the agent to invoke only MCP server A (deployed in its own module/state)
# resource "google_cloud_run_v2_service_iam_member" "agent_invokes_mcp_a" {
#   name     = "mcp-server-a"
#   location = var.region
#   role     = "roles/run.invoker"
#   member   = "serviceAccount:${google_service_account.agent.email}"
# }
