# Coverage evidence

Load this reference before using a test plan or coverage report, and whenever a review assigns `covered`, `missing`, or `unverified`.

`f-testing` (verify mode) owns full coverage audits and coverage reports. Do not produce or refresh one in a review.

## Which files

Resolve candidates before applying the evidence rules. Use `docs/tests/index.md` (`Source | Mode | Revision | File`) as a path hint and confirm each candidate on the filesystem. A missing or stale index does not hide a unique filename match.

A filename matches only when it is exactly `TEST-<source-id>-plan.md` or `TEST-<source-id>-coverage.md`. `TEST-REQ-0010-plan.md` is not a match for `REQ-001`.

Resolve:

- the reviewed unit (`TASK-004`, `REQ-001`, or the branch slug from File Naming in the skill)
- when that unit is a task whose **Source** is a REQ-ID, also `TEST-<REQ-ID>-plan.md` and `TEST-<REQ-ID>-coverage.md`

Read every unique match. Apply the evidence rules below to each coverage report on its own. Cite the file that supports each coverage state.

## Test plans and verify reports

Paths: `docs/tests/TEST-<source-id>-plan.md` and `docs/tests/TEST-<source-id>-coverage.md`. When a reviewed task's Source is a REQ-ID, those two filenames for that REQ-ID are paths as well.

A test plan describes intended coverage, not implemented tests. A verify report describes statically inspected tests. Neither proves that tests ran successfully.

Before using a verify report, validate its `Verified inputs` table:

- Each repository-relative path must exist.
- Its SHA-256 must match the raw file contents in the reviewed revision or working tree, as appropriate.
- Hash a committed revision with `git show <rev>:<path> | sha256sum`.
- Hash a working-tree file with `sha256sum <path>`.
- The report must identify the source AC documents, inspected tests, and relevant test helpers/configuration.

Missing metadata, unavailable inputs, changed hashes, or an AC source that cannot be matched to the reviewed criteria make the report unusable as current evidence. Without independent direct evidence, use `unverified`. Focused inspection of the diff and relevant tests is allowed under the rules below. Do not refresh the report or perform a full coverage audit.

## Coverage states

A `Check` is the concrete verification statement of an acceptance criterion (defined by `f-requirements`; mapped to tests by `f-testing`). State test coverage as `covered`, `missing`, or `unverified`:

- `covered` from a current verify report with a concrete matching test reference, or focused inspection of a test and its identifiable assertion that satisfies the Check in the reviewed revision or working tree.
- `missing` from a current verify report that documents the gap, or direct evidence from the diff and focused inspection of relevant tests. Cite the Check, the evidence, and the inspected scope; for a deleted required test, check for a replacement. A test absent from the diff or a filename search alone does not establish a gap. A plan alone is never evidence of implemented or missing tests.
- `unverified` when neither a current report nor focused inspection establishes coverage or a concrete gap; disclose any inspection limits.

Rules:

- Map a current report's `partial` to `unverified` and note the partial coverage. A concrete documented gap may still be a finding under the rule below; never promote `partial` to `covered`.
- `missing` becomes a finding only when the criterion's `Check` cannot be satisfied without a test.

Keep direct inspection limited to the reviewed criteria and affected test paths, including relevant helpers/configuration. Cite the evidence used for each coverage state and explain any disagreement with an existing report. Direct inspection does not make a stale report current or prove that tests pass.
