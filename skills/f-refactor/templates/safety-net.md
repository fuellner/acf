# Safety net: {{UNIT_ID}}

**Type**: {{migration | refactor}}  
**Updated**: {{DATE}}  
**Test plan**: {{docs/tests path, or "not written yet"}}

`f-testing` writes the test plan. This file is the scope.

## Seams

| Seam | Oracle | Runtime to lock | Notes |
|------|--------|-----------------|-------|
{{SEAM_ROWS}}

## Golden masters

Normalize these before any compare. Freeze them to a constant in the fixture output: timestamps, generated ids, session tokens, random values. Add a row when a seam has another unstable field.

| Golden file | Normalized fields | Why those fields |
|-------------|-------------------|------------------|
{{GOLDEN_ROWS}}

A change to a golden file needs a reason on the step record. Do not refresh a snapshot because the new runtime differs. For a migration, the same suite runs under the old runtime and the target runtime, and the normalized outputs are diffed.

## Data

Fixtures are anonymized or synthesized. No production or customer data. No secrets.

## Deferred seams

{{what the fast path is not covering, or "None."}}
