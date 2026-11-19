# IAM Design

Use one service account per component. Role names below are standard predefined roles; verify them against current Google Cloud documentation and prefer narrower custom roles where practical.

| Identity | Purpose | Roles (illustrative) | Must not have |
|---|---|---|---|
| `agent-sa` | Runs the agent service | `roles/aiplatform.user` (call Gemini), `roles/logging.logWriter`, `roles/secretmanager.secretAccessor` on specific secrets only, `roles/run.invoker` on specific MCP services only | Project-wide secret access, editor/owner, access to MCP data stores |
| `mcp-a-sa` | Runs MCP server A | Only the data-store role it needs (for example read on one dataset), `roles/logging.logWriter` | Access to other servers' data, model access unless required |
| `deployer-sa` | CI/CD deploys | `roles/run.developer`, `roles/artifactregistry.writer`, `roles/iam.serviceAccountUser` on the runtime SAs only | Secret values, broad project roles |
| End users | Call the agent | Authenticated at the edge; `roles/run.invoker` held by the load balancer path, not by users directly | Direct invoke on MCP servers |

## Practices
- **Grant at the narrowest resource.** Bind roles on the specific secret, service, or dataset, not the project.
- **No service account keys.** Use the attached identity (ADC). CI authenticates with Workload Identity Federation.
- **Service-to-service auth.** The caller fetches an ID token with the callee's URL as audience. The callee verifies it and checks the caller's identity.
- **Organization policies** where available: disable service account key creation, restrict public invocation, restrict allowed regions.
- **Review.** Use IAM Recommender and policy analysis to find unused permissions; require review for IAM changes.
