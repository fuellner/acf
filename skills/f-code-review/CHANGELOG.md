# Changelog

## 2026-10-27
- Refactor and migration units get a behavior-preservation check (`references/safety-checks.md`): a migration fails on a non-forced change, a refactor fails on a version bump, and a bug fixed instead of recorded is a finding.
- A golden-master update without a reason on the step is a finding. A migration review expects the same suite diffed on the old and target runtimes.
- An APPROVED or CHANGES REQUIRED review updates the linked `f-refactor` step status. The unit becomes `done` only when the user asked to close it, every step is `done` or `skipped`, and the done criteria were reviewed.
- Requirement completion now tests review evidence instead of the coverage term `unverified`; `[test: unverified]` coverage alone does not block `done` when the criterion has review evidence.
- `CONCERN` no longer blocks completion: overall Spec Compliance can be PASS, CONCERN, or FAIL, and the APPROVED transition accepts PASS or CONCERN. Requirement `done` now requires review evidence for every criterion of the linked requirement.
- Fix prompt consolidated: `templates/fix-prompt.md` is now the single canonical source; the inline copy in the output template was removed (both had drifted). The template heading follows the file-naming chain vocabulary, the verification placeholder explains its default, the `blocked` ownership sentence matches the f-debug fix prompt, and the no-open-findings case is documented.
- `references/coverage-evidence.md` defines `Check` up front and lists the three coverage states before the mapping rules.

## 2026-10-26
- Coverage-evidence and SHA-256 rules moved to `references/coverage-evidence.md`. Load that file before using a test plan or verify report and when assigning a coverage state.
- Directory indexes follow the shared `references/directory-index.md` instead of an inlined copy. Review-specific constraints stay here: preserve requirement index statuses on CHANGES REQUIRED, and do not create a review directory for an unsaved review.
- `blocked` is set only by the user or the implementing agent. This skill may recommend it and must not set it. The fix prompt says the same.
- Debug reports stay in `docs/debug/`. A review links to one for the same unit and does not copy it into `docs/reviews/`.
- `CONCERN` is defined, and the verdict self-check now covers consistency with open findings, not only with the criteria.
- Security bullet clarified: missing validation at system boundaries.
- SHA-256 validation names the hash command for a committed revision and for the working tree.
- Directory index wording aligned with the other skills.
- Allow focused diff/test inspection as direct evidence of coverage or a concrete gap, with Check references, inspected scope, and replacement checks for deleted required tests. Stale reports remain invalid; full coverage audits stay with f-testing.
- Maintain `index.md` in every affected documentation directory and parent below `docs/`, including saved reviews and status/traceability targets. Rebuild missing indexes from existing contents while preserving authored prose and status rules.
- Review fixes F-01/F-02/F-04/F-07: plans no longer establish coverage; verify reports require matching SHA-256 input fingerprints, and partial coverage stays unverified.
- Explicit re-reviews retain unresolved blockers, record resolutions, and cannot approve while a Critical/High finding remains unresolved.
- Task status propagation resolves exact IDs across slugged and legacy filenames, rejecting ambiguous matches.
- Requirement completion synchronizes Updated and the requirement index, rebuilding a missing index from existing documents.
- Stage 1 now takes acceptance criteria from `docs/requirements/REQ-*.md` as the canonical file source.
- Full coverage assessments and coverage reports belong to `f-testing` (verify); reviews use current verify reports or focused direct evidence, otherwise marking coverage `unverified`. Test plans alone do not establish coverage.
- Coverage state added to the acceptance criteria output line and to the self-check.
- Added **Status Propagation**: an APPROVED review sets the referenced task to `done`, updates `Updated` and the tasks index, and appends the review path to the requirement's `Traceability → Reviews`.
- CHANGES REQUIRED sets the task to `changes-requested`; the fix prompt is the handoff.
- Requirement `done` only when every criterion of that requirement passes.
- Report location is now `docs/reviews/`, with a naming rule based on the reviewed unit and a `Revision` counter instead of date suffixes.
- Fix prompt extracted to `templates/fix-prompt.md` with the same field names as f-debug.
- Documentation-only scope made explicit; code edits and automatically started re-reviews remain forbidden.
- Added a "Before you finish" self-check.

## 2026-10-23
- Initial creation of f-code-review skill.
