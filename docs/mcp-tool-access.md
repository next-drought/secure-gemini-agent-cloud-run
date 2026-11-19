# MCP Tool Access Control

MCP lets an agent discover and call tools. The risk is that the model's decisions, which can be steered by untrusted text, translate into real actions. Put a policy layer between the model and the servers.

## Controls
1. **Allowlist servers and tools.** Only pre-approved MCP servers are reachable. Tool lists are pinned per agent role, not accepted dynamically from the server at runtime. Re-review when a server's tool list changes.
2. **Authenticate each server.** Servers run as separate Cloud Run services requiring authentication. The gateway sends an ID token with the server URL as audience; servers verify it.
3. **Authorize per call.** The gateway checks that this end user is allowed to use this tool with these arguments. The agent's own permissions are not enough (confused deputy).
4. **Scope credentials per tool.** Each server uses its own service account with access to only its data. Do not share one broad identity.
5. **Classify tools by effect:**
   | Class | Examples | Policy |
   |---|---|---|
   | Read-only, low sensitivity | search public docs | Allow |
   | Read sensitive | query customer records | Allow with user-level authorization and logging |
   | Write / state-changing | create ticket, send email | Require user confirmation showing the exact action |
   | Destructive / high impact | delete data, change IAM | Do not expose to the agent |
6. **Validate arguments and results.** Schema-validate arguments, enforce size limits, and strip or flag results that contain instruction-like content. Treat results as data.
7. **Limit loops and rate.** Cap tool calls per request and per user, and set timeouts.
8. **Restrict egress-capable tools.** A generic "fetch any URL" or "run code" tool is an exfiltration and injection path. If needed, restrict destinations and run in a sandbox without credentials.
9. **Log every decision** with request ID, user, tool, and outcome.

## New-tool review (copy into a pull request)
- Owner and purpose:
- Data and systems it can reach:
- Identity and roles it runs with:
- Effect class (read / write / destructive):
- Confirmation required?
- Input and output validation:
- Rate limit and timeout:
- What happens if an attacker controls the model's request?
