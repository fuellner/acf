# Debugging Notes (optional)

Load this file only when the failure type is unusual or standard evidence is insufficient.

## Lightweight Heuristics
- Prefer the smallest code path that explains the observed failure.
- Stack traces point to the symptom; walk upward only as far as evidence requires.
- Failing tests usually encode both the expected behavior and the trigger; start there.
- Logs that appear only under specific conditions are higher-value evidence than generic error messages.
- If two hypotheses fit the evidence equally well, request the distinguishing observation rather than choosing.

## Common Pitfalls to Avoid
- Treating a symptom as the root cause.
- Proposing a fix that also "improves" surrounding code.
- Claiming reproducibility without concrete steps.
