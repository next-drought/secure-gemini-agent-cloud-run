# Threat Model

Method: asset and trust-boundary analysis with STRIDE-style categories, mapped to the OWASP Top 10 for LLM Applications (2025).

## Assets
- User data and conversation content
- Credentials (service account identity, secrets)
- Data reachable through tools
- Model access and quota (cost)
- Audit trail integrity

## Threats and mitigations
| # | Threat | Category | OWASP LLM | Mitigations | Residual risk |
|---|---|---|---|---|---|
| T1 | User or document injects instructions that change agent behavior (direct or indirect prompt injection) | Tampering / EoP | LLM01 | Treat all input and retrieved text as untrusted; no authority in prompts; tool policy enforced in code; confirm state-changing actions; limit tool set per task | Cannot be fully eliminated. Assume injection succeeds and limit blast radius |
| T2 | Agent calls a tool beyond the user's rights (confused deputy) | EoP | LLM06 | Tool gateway checks the end user's permissions, not only the agent's; per-tool scopes; separate identities per MCP server | Misconfigured scopes |
| T3 | Secret exposure (API key in client bundle, logs, image, or prompt) | Info disclosure | LLM02 | Secrets in Secret Manager, mounted at runtime; keyless Vertex AI auth; never in prompts; scan repos and images; log redaction | Developer error |
| T4 | Sensitive data leaks in model output or logs | Info disclosure | LLM02, LLM07 | Data minimization in prompts; output filtering; do not put secrets in system prompts; log metadata not raw content by default | Model memorized or retrieved sensitive data |
| T5 | Malicious or compromised MCP server or tool result | Tampering | LLM03, LLM05 | Allowlist of vetted servers; pin versions and images by digest; authenticate servers; validate and size-limit results; treat results as data | Supply-chain compromise upstream |
| T6 | Unsafe handling of model output (XSS, command or SQL injection) | Tampering / EoP | LLM05 | Encode output for its sink; parameterized queries; no model-generated shell execution without sandbox | Edge cases in rendering |
| T7 | Data exfiltration via tool calls or egress | Info disclosure | LLM02, LLM06 | VPC egress controls, destination allowlist; no generic "fetch URL" tool or restrict it; VPC Service Controls where available | Allowed destinations abused |
| T8 | Resource exhaustion and cost abuse | DoS | LLM10 | Edge rate limits and quotas; max tokens, max tool-loop iterations, request timeouts; Cloud Run max instances; budget alerts | Bursts within limits |
| T9 | Poisoned or untrusted RAG content or embeddings | Tampering | LLM04, LLM08 | Ingestion allowlist and provenance; per-tenant access control at retrieval; separate indexes per trust level | Subtle poisoning |
| T10 | Over-privileged service account or deployer | EoP | n/a | Dedicated SAs, minimal roles, no owner/editor, CI uses workload identity federation, review IAM changes | Role drift |
| T11 | Tampered image or dependency | Tampering | LLM03 | Dependency pinning and scanning; Artifact Registry; deploy by digest; Binary Authorization | Zero-day in dependency |
| T12 | Missing or tamperable audit trail | Repudiation | n/a | Structured logs with request ID and identity; Cloud Audit Logs; log sink to a separate project/bucket with restricted write | Log gaps for unlogged paths |
| T13 | Confidently wrong output relied on for decisions | n/a | LLM09 | Human review for consequential actions; citations to sources; scope the agent's role | Inherent to LLMs |

## Assumptions
- The model provider is trusted to operate the service, but model output is not trusted.
- Attackers can control user input and any content the agent retrieves.
- Attackers cannot access the GCP project directly; project-level IAM is administered separately.

## Out of scope
Model training security, end-user device security, and organization-wide policy beyond the project.

## Review cadence
Revisit when adding a tool, a data source, or a new trust level. Each new MCP server needs a short entry: owner, data accessed, scopes, confirmation rules.
