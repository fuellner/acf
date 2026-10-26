# Coverage evidence

Load this reference before using a test plan or coverage report, and whenever a review assigns `covered`, `missing`, or `unverified`.

`f-testing` (verify mode) owns full coverage audits and coverage reports. Do not produce or refresh one in a review.

## Test plans and verify reports

Paths: `docs/tests/TEST-<source-id>-plan.md` and `docs/tests/TEST-<source-id>-coverage.md`.

A test plan describes intended coverage, not implemented tests. A verify report describes statically inspected tests. Neither proves that tests ran successfully.

Before using a verify report, validate its `Verified inputs` table:

- Each repository-relative path must exist.
- Its SHA-256 must match the raw file contents in the reviewed revision or working tree, as appropriate.
- Hash a committed revision with `git show <rev>:<path> | sha256sum`.
- Hash a working-tree file with `sha256sum <path>`.
- The report must identify the source AC documents, inspected tests, and relevant test helpers/configuration.

Missing metadata, unavailable inputs, changed hashes, or an AC source that cannot be matched to the reviewed criteria make the report unusable as current evidence. Without independent direct evidence, use `unverified`. Focused inspection of the diff and relevant tests is allowed under the rules below. Do not refresh the report or perform a full coverage audit.

## Coverage states

State test coverage as `covered`, `missing`, or `unverified`:

- `covered` from a current verify report with a concrete matching test reference, or focused inspection of a test and its identifiable assertion that satisfies the Check in the reviewed revision or working tree.
- `missing` from a current verify report that documents the gap, or direct evidence from the diff and focused inspection of relevant tests. Cite the Check, the evidence, and the inspected scope; for a deleted required test, check for a replacement. A test absent from the diff or a filename search alone does not establish a gap. A plan alone is never evidence of implemented or missing tests.
- Map a current report's `partial` to `unverified` and note the partial coverage. A concrete documented gap may still be a finding under the rule below; never promote `partial` to `covered`.
- `missing` becomes a finding only when the criterion's `Check` cannot be satisfied without a test.
- `unverified` when neither a current report nor focused inspection establishes coverage or a concrete gap; disclose any inspection limits.

Keep direct inspection limited to the reviewed criteria and affected test paths, including relevant helpers/configuration. Cite the evidence used for each coverage state and explain any disagreement with an existing report. Direct inspection does not make a stale report current or prove that tests pass.
