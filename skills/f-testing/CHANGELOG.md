# Changelog

## 2026-10-26
- Directory indexes follow the shared `references/directory-index.md`.
- Status handling states that this skill does not set `blocked`.
- f-testing no longer writes into task documents (`Verification` section); the coverage report is the only handoff, so task updates stay with f-tasks, the implementing agent, and f-code-review. Task index maintenance dropped accordingly.
- Hash command for committed revisions added (`git show <rev>:<path> | sha256sum`).
- Directory index wording aligned with the other skills.
- Align the review handoff with focused direct diff/test evidence while retaining hash validation and ownership of full coverage audits/reports.
- Maintain directory indexes for test artifacts, task Verification updates, and nested parents below `docs/`, rebuilding missing indexes from existing contents without changing statuses.
- Review fix F-01: distinguish planned coverage, static test inspection, and executed tests. Verify reports record SHA-256 fingerprints for AC documents, tests, and relevant helpers/configuration.
- The coverage template now includes Verified inputs, Updated, and an explicit static-inspection evidence statement. Reviews must validate report freshness; partial coverage never becomes covered.
- Added a file-naming and revision rule: one file per source unit, no dated or versioned copies, `Revision` increments on update.
- Templates carry a `Revision` field.
- Added a "Before you finish" self-check.
- The coverage report is now explicitly the single authoritative coverage source that f-code-review consumes.

## 2026-10-25
- Initial version of f-testing skill.
- Supports generate (test plan from Checks) and verify (coverage report) modes.
- Templates for test plan, coverage report, and optional skeleton.
- References with Check-to-test mapping examples.
