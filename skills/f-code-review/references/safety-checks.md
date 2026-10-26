# Safety Check References

Load only when Stage 2 needs more detail.

## Security (quick list)
- Parameterized queries / no string-concatenated SQL or shell
- AuthZ check present before sensitive data or actions
- No secrets, tokens, or PII in source or logs
- Input validated at boundaries; internal trust is OK
- No unsafe eval, deserialization of untrusted data, or open redirects

## Performance (quick list)
- No unbounded queries or loops over user-controlled size
- No N+1 in changed paths
- Heavy work not on request hot path without reason
- Pagination or limits where result sets can grow

## Side effects (quick list)
- Existing callers / consumers still behave as before
- Public contracts (API, events, DB schema) unchanged or migrated
- No hidden mutations outside the intended scope
- No new global state or singleton side effects

Only raise a finding when you can point to the exact lines and explain the concrete risk.