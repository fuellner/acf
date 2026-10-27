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

## Behavior preservation (f-refactor)

Apply only when the task source, the linked plan, or the user identifies the change as an `f-refactor` unit. Read `Type` from the plan header.

Both types:

- Observable behavior outside the stated step is unchanged.
- A bug fixed in this diff, instead of recorded on the step, is a finding.
- A follow-up unit of the other type is not a defect.

Migration:

- Every change is forced by the target runtime, framework, or dependency upgrade, or is a deletion the plan marks as proven-dead.
- A rename, restructure, new abstraction, or voluntary dependency swap is a finding.

Refactor:

- No PHP, framework, or dependency version bump.
- A characterization assertion edited to match new behavior is a finding.
- A golden-master file changed without a reason on the step record is a finding. On a migration, the same suite must have been diffed on the old runtime and the target runtime.