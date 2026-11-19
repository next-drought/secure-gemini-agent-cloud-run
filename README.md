# Secure Gemini Agent on Cloud Run: Reference Architecture and Threat Model

A reusable reference design for running an LLM agent (Gemini on Vertex AI) with tool access through MCP servers on Google Cloud Run. It covers identity and IAM, secrets, network boundaries, logging, and how to constrain tool access. It includes a threat model mapped to the OWASP Top 10 for LLM Applications.

**Status:** design documentation plus an illustrative Terraform skeleton. The Terraform has not been applied or validated against a live project. Treat it as a starting point and review it before use. All content is generic and based on public Google Cloud documentation. It contains no employer material.

## Contents
| Doc | What it covers |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Components, trust boundaries, request flow, design principles |
| [docs/threat-model.md](docs/threat-model.md) | Assets, trust boundaries, threats, mitigations, residual risk, OWASP LLM mapping |
| [docs/iam.md](docs/iam.md) | Service accounts, roles, and what each identity may do |
| [docs/secrets-and-logging.md](docs/secrets-and-logging.md) | Secret handling and what to log (and not log) |
| [docs/mcp-tool-access.md](docs/mcp-tool-access.md) | Controlling which tools the agent can call and with what authority |
| [docs/checklist.md](docs/checklist.md) | Pre-production review checklist |
| [terraform/](terraform/) | Illustrative infrastructure skeleton |

## Core ideas
1. The agent is untrusted code driven by untrusted input. Authorization lives outside the model.
2. One service account per component, each with only the roles it needs. No API keys in the client or the image.
3. Tool calls go through a policy layer that allowlists tools, scopes credentials per tool, and requires confirmation for state-changing actions.
4. Tool output and retrieved content are untrusted data, not instructions.
5. Log decisions and tool calls with identity and request IDs, but not secrets or raw sensitive content.

## License
MIT. See [LICENSE](LICENSE).
