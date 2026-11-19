# Secrets and Logging

## Secrets
- **Prefer no secret.** Gemini on Vertex AI is called with the service account via ADC, so there is no API key to store. Avoid the pattern of embedding an API key in a browser bundle (for example a Vite `import.meta.env` or `define` value): anything in a client bundle is readable by every visitor. Put the model call behind a backend.
- **When a secret is needed** (third-party API), store it in Secret Manager and expose it to Cloud Run as an environment variable or mounted file via a secret reference, not as a plaintext value in config or the image.
- **Grant access per secret** to the one service account that needs it. Pin to a version or use `latest` deliberately, and rotate on a schedule.
- **Detect leaks.** Run secret scanning in CI and on the repository. If a key was ever committed, rotate it; deleting the commit is not enough.
- **Never put secrets in prompts or system instructions.** Assume the model can be induced to reveal them.

## Logging
Log enough to investigate an incident and prove what happened, without storing sensitive content unnecessarily.

| Log | Why | Notes |
|---|---|---|
| Request ID, authenticated user ID, timestamp | Attribution and correlation | Propagate the ID to every tool call |
| Tool call: tool name, argument shape, decision (allowed/denied/confirmed), result status | Detect abuse and over-reach | Redact or hash sensitive argument values |
| Model call: model, token counts, latency, safety or filter outcome | Cost and anomaly detection | Raw prompts/responses off by default; enable with a retention limit when needed |
| Policy denials and confirmation prompts | Tuning and detection | Alert on spikes |
| Cloud Audit Logs: Admin Activity (always on), Data Access for Secret Manager and Vertex AI where enabled | Who changed or read what | Data Access logs can be large; enable deliberately |

**Handling**
- Use structured JSON logs so Cloud Logging can filter on fields.
- Route security-relevant logs through a sink to a separate project or bucket with restricted write and a defined retention period.
- Create log-based alerts for: repeated tool denials, access to unexpected secrets, unusually long tool loops, token-usage spikes.
