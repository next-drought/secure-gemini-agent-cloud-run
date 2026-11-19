# Pre-production Checklist

**Identity and access**
- [ ] Separate service account per component; no owner/editor roles
- [ ] No service account keys; CI uses Workload Identity Federation
- [ ] Cloud Run services require authentication; MCP servers not publicly invokable
- [ ] Roles granted on specific resources, not the project

**Secrets**
- [ ] No API key in any client bundle, image, repo, or prompt
- [ ] Secrets in Secret Manager with per-secret access
- [ ] Secret scanning enabled; rotation plan exists

**Network**
- [ ] Ingress limited to the load balancer; Cloud Armor and rate limits configured
- [ ] Egress controlled; no unrestricted URL-fetch tool

**Agent and tools**
- [ ] Tool allowlist pinned per role; new-tool review completed
- [ ] State-changing tools require confirmation; destructive tools not exposed
- [ ] Max tokens, max tool iterations, and timeouts set
- [ ] Output encoded for its sink; tool and retrieval content treated as untrusted

**Supply chain**
- [ ] Dependencies pinned and scanned; images deployed by digest
- [ ] Dependabot and code scanning enabled

**Observability**
- [ ] Structured logs with request ID and user ID; sensitive content redacted
- [ ] Audit logs routed to a restricted sink
- [ ] Alerts: denial spikes, unexpected secret access, token-usage spikes, budget
