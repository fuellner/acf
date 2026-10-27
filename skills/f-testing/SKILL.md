---
name: f-testing
description: >
  Derives concrete, executable tests from the Check part of strict acceptance
  criteria (Given/When/Then + Check + Must-not) or verifies that existing tests
  cover those Checks. Produces test plans or coverage reports so implementing
  agents have clear, checkable test instructions. Links to REQ/TASK IDs.
  Use when the user wants tests generated from requirements or tasks, a coverage
  check against acceptance criteria, or test skeletons for an implementing agent.
  Triggers on: "create tests from requirements", "generate tests for TASK",
  "check test coverage against ACs", "test plan from REQ", "do we cover the checks",
  "write test skeletons", "characterization tests", "lock current behavior".
  Do NOT use for implementing production code, running tests, code review,
  executing a migration or refactor, or general documentation.
---

# Testing

Lightweight, agent-agnostic skill that turns the Check statements of acceptance
criteria into concrete test instructions or verifies existing coverage.
Does not implement production code and does not execute tests.

## Input

Accept any of the following (provided by the user; do not hard-code tool or MCP calls):

- Requirement document(s) from `docs/requirements/` or pasted
- Task document(s) from `docs/tasks/` or pasted
- Free-text description that already contains strict ACs with Checks
- Existing test code or file paths (for verify mode)
- A refactor plan or step that names behavior to lock (characterization)
- Explicit request to update an existing test plan

If a source is referenced but content is missing, ask once. Do not invent acceptance criteria or Checks.

## Modes

### generate
Create a test plan that maps each Check to a concrete test.
The plan describes intended coverage; it is not evidence that tests exist.

### verify
Compare existing tests against the Checks and produce a coverage report.
This is static inspection, not test execution; the report does not establish that tests pass.

## Workflow

1. Identify the source (REQ-ID, TASK-ID, or free text) and extract all Acceptance Criteria with their Check statements.
2. Determine the mode (generate or verify) from the user request. Default to generate if unclear.
3. For **generate**:
   - Create one test entry per Check.
   - Suggest a test name that includes the AC or Check reference.
   - Fill `**Maps to**` with the criterion's AC identifier (`AC-2`) or its Check reference.
   - Map Given/When/Then to setup / action / assertion.
   - Carry the criterion's `Must not` constraint into the entry's `**Must not**` line; omit the line when the criterion has none.
   - Mark any test that goes beyond the original Checks with `*(supplemented)*`.
   - When the source is an `f-refactor` step or plan that asks to lock current behavior, treat each named behavior as the Check. The entry asserts the observed result, including quirks, and is marked `*(characterization)*`. Do not add entries for desired behavior the code does not have, and do not cover modules the step does not name.
   - Note the expected test type (unit / integration / e2e) only when obvious from context.
4. For **verify**:
   - Locate the relevant existing tests (user-provided or obvious paths).
   - For each Check state: covered | partial | missing. For `covered` and `partial`, cite the concrete test and assertions; for `partial` and `missing`, describe the precise gap.
   - Flag any missing test that would become a finding in a later review.
   - Record `Verified inputs` with repository-relative paths and SHA-256 hashes of the raw contents inspected: source AC documents, inspected tests, and relevant test helpers/configuration. Use a read-only hash command against the same revision or working tree used for inspection: `sha256sum <path>`, or `git show <rev>:<path> | sha256sum` for a committed revision. Check that the inputs have not changed before writing the report.
   - If ACs or tests were only pasted, identify that limitation in Notes; do not invent file paths or hashes. Such a report cannot establish current coverage in a later review until its inputs can be matched to repository files.
5. Write the output using the appropriate template:
   - `docs/tests/TEST-<source-id>-plan.md` (generate)
   - `docs/tests/TEST-<source-id>-coverage.md` (verify)
   Name the file after the reviewed unit (`REQ-001`, `TASK-004`), never after the date or the author. On an explicit update request, overwrite the same file, increment `Revision`, and update `**Updated**` inside it; do not add version suffixes — Git is the history.
6. Report what was created or updated.

Updates to existing test plans are allowed only when the user explicitly requests an update.

## Rules

- Language: English.
- Use the templates. Do not invent additional top-level sections.
- Prefer the smallest change. Do not invent Checks that were not present.
- One Check → one test entry (or one clearly bounded assertion group).
- Do not implement production code. Do not execute tests. Do not perform reviews.
- Sequential identifiers are stable; reuse the source REQ/TASK ID in the filename.
- One file per source unit. Updates overwrite the same file and increment `Revision`; no dated or versioned copies.

## Output Rules

Always include:
- Source (REQ-ID / TASK-ID)
- Mode (generate | verify)
- List of Checks with their corresponding test or coverage status
- In verify mode, `Verified inputs` with actual paths and content hashes, plus any limitation that prevents their validation

## Status Handling

This skill does not change task or requirement status. It does not set `blocked`; only the user or the implementing agent does.
If tests are missing that would later be flagged in review, note it in the coverage report. Task documents belong to f-tasks and the implementing agent; do not edit them.

The verify report provides statically inspected coverage evidence for a later review, provided its inputs still match. `f-code-review` validates the recorded hashes without repeating the full coverage assessment and may also use focused inspection of the reviewed diff and relevant tests to establish coverage or a concrete gap. Missing or changed inputs invalidate the report's evidence; without independent direct evidence, use `unverified`. A report's `partial` maps to `unverified` with its documented gap retained. Direct inspection does not refresh the report. A plan alone never establishes coverage, and neither artifact proves a successful test run.

## Templates

All templates live relative to this skill:

- `templates/test-plan.md` — generated test plan
- `templates/coverage-report.md` — coverage check result
- `templates/test-skeleton.md` — optional test skeleton (JavaScript example; adapt to the project's language)

## Documentation Location

Write all output under `docs/tests/` in the target repository.

Follow `references/directory-index.md` whenever creating or updating documentation under `docs/`. Do not change task or requirement status.

## References

- `references/directory-index.md` — shared `index.md` rules. Follow it when writing documentation.
- `references/check-to-test-examples.md` — read when you need concrete mapping patterns.

## Before you finish

- Every Check has exactly one test entry (generate) or one explicit status (verify).
- Characterization entries are marked `*(characterization)*` and assert observed behavior, including quirks.
- Every test name references its AC or Check.
- Anything added beyond the Checks is marked `*(supplemented)*`.
- The file follows the naming rule and states source + mode + revision.
- Verify reports identify the inspected AC/test inputs and their SHA-256 hashes, or explicitly disclose why those inputs cannot be validated. Test references and coverage gaps are concrete; no test execution is claimed.
- No unfilled `{{...}}` placeholder or `…` filler remains in new or edited sections.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve.
