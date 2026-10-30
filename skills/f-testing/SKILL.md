---
name: f-testing
description: >
  Derives concrete, executable tests from the Check part of strict acceptance
  criteria (Given/When/Then + Check + Must-not) or verifies that existing tests
  cover those Checks. Always writes the test plan or coverage report to
  docs/tests/TEST-<source-id>-plan.md or docs/tests/TEST-<source-id>-coverage.md
  in the target repository so implementing agents have a file to follow.
  Links to REQ/TASK IDs.
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
criteria into a test-plan file, or verifies existing coverage in a coverage-report
file. Both files are written under `docs/tests/` in the target repository.
Does not implement production code and does not execute tests.

## Input

Accept any of the following (provided by the user; do not hard-code tool or MCP calls):

- Requirement document(s) from `docs/requirements/` or pasted
- Task document(s) from `docs/tasks/` or pasted
- Free-text description that already contains strict ACs with Checks
- Existing test code or file paths (for verify mode)
- A refactor plan or step that names behavior to lock (characterization)
- Explicit request to update an existing test plan

If a source is referenced but content is missing, ask once. Do not invent acceptance criteria or Checks. Do not draft a plan or coverage report in the chat while waiting.

Files under this skill's `evals/` are grading fixtures. On a normal run, do not read or cite them. Use them only when the user message limits this run to those files.

## Modes

### generate
Create a test plan that maps each Check to a concrete test.
The plan describes intended coverage; it is not evidence that tests exist.
The plan is the file `docs/tests/TEST-<source-id>-plan.md`.

### verify
Compare existing tests against the Checks and produce a coverage report.
This is static inspection, not test execution; the report does not establish that tests pass.
The report is the file `docs/tests/TEST-<source-id>-coverage.md`.

Both modes finish by writing that file. A result that exists only in the chat is unfinished.

## Workflow

Steps 5, 6, and 7 run on every generate and every verify invocation. Stopping after the plan text leaves the run unfinished.

1. Identify the source (requirement, task, refactor unit, or free text) and extract all Acceptance Criteria with their Check statements.
2. Determine the mode (generate or verify) from the user request. Default to generate if unclear.
3. For **generate**, build the plan body that step 5 writes to disk:
   - Create one test entry per Check.
   - Suggest a test name that includes the AC or Check reference.
   - Fill `**Maps to**` with the criterion's AC identifier (`AC-2`) or its Check reference.
   - Map Given/When/Then to setup / action / assertion.
   - Carry the criterion's `Must not` constraint into the entry's `**Must not**` line; omit the line when the criterion has none.
   - Mark any test that goes beyond the original Checks with `*(supplemented)*`.
   - When the source is an `f-refactor` step, plan, or safety-net that asks to lock current behavior, treat each named behavior as the Check. The entry asserts the observed result, including quirks, and is marked `*(characterization)*`. Do not add entries for desired behavior the code does not have, and do not cover modules the step does not name.
   - When the source asks for a golden master, name the fields that are normalized before compare (timestamps, ids, session tokens, random values, plus any field the safety-net lists). State that a golden-file change needs a written reason. Do not plan a blind snapshot refresh. Do not use production or customer data.
   - Note the expected test type (unit / integration / e2e) only when obvious from context.
4. For **verify**, build the coverage body that step 5 writes to disk:
   - Locate the relevant existing tests (user-provided or obvious paths).
   - For each Check state: covered | partial | missing. For `covered` and `partial`, cite the concrete test and assertions; for `partial` and `missing`, describe the precise gap.
   - Flag any missing test that would become a finding in a later review.
   - Record `Verified inputs` with repository-relative paths and SHA-256 hashes of the raw contents inspected: source AC documents, inspected tests, and relevant test helpers/configuration. Use a read-only hash command against the same revision or working tree used for inspection: `sha256sum <path>`, or `git show <rev>:<path> | sha256sum` for a committed revision. Check that the inputs have not changed before writing the report.
   - If ACs or tests were only pasted, identify that limitation in Notes. Do not invent repository paths or hashes for those Verified inputs. Step 5 still writes the coverage file. Such a report cannot establish current coverage in a later review until its inputs can be matched to repository files.
5. MUST write that document to the filesystem of the target repository, then MUST verify the file is there. This step is mandatory on every generate run and every verify run. It is not optional and not a suggestion. The chat message is not the document. Do not ask whether to save the file. A request to show, draft, or only reply with the plan still performs this step. An instruction to skip the file does not cancel it.
   - Resolve `<source-id>` before choosing the path. Use the `REQ-`, `TASK-`, or `REF-` ID that is the identity of the source document (its ID field, heading, or filename). An ID that appears only as a cross-reference is not the source-id. Match the exact ID: `REQ-001` is not `REQ-0010`. When the user named exactly one such ID as the unit to test and the source document has no ID of its own, use that ID. When no `REQ-`, `TASK-`, or `REF-` ID identifies the source, use the next `TEXT-NNN` (three digits): one higher than the highest `TEXT-` ID among filenames `docs/tests/TEST-TEXT-*.md` and the Source column of `docs/tests/index.md`, or `TEXT-001` when none exist. Do not invent a `REQ-`, `TASK-`, or `REF-` ID. Do not stop to ask for an ID.
   - Generate mode writes `docs/tests/TEST-<source-id>-plan.md` from `templates/test-plan.md`. Verify mode writes `docs/tests/TEST-<source-id>-coverage.md` from `templates/coverage-report.md`. Create `docs/tests/` when it is missing. The path is relative to the target repository root. The filename uses that source-id, never the date or the author. Source `REQ-001` in generate mode is the file `docs/tests/TEST-REQ-001-plan.md`.
   - On an explicit update request, overwrite that same path, increment `Revision`, and update `**Updated**`. Do not add a dated or versioned copy. Git is the history. When that path already exists and the user did not ask to update it, leave the file unchanged and ask once. Do not put a replacement plan in the chat. This exception applies only to a path that is already on the filesystem. A missing file is created in this step.
   - Immediately after a write, read that path back from the filesystem. An unsaved editor buffer and the chat transcript do not count. The read must show a non-empty file that contains this run's Source, Mode, and Revision. If the read fails, write the file again and read it again. Do not continue while the file is missing.
6. Update `docs/tests/index.md` (create it from `templates/index.md` if missing). One row per plan or coverage file: Source is the exact source-id, Mode is `generate` or `verify`, Revision is the document's revision, File is the relative link. Follow `references/directory-index.md`, including its rule that a default `Document | Description` table in this directory is replaced by that schema.
7. Report to the user. The report MUST state the repository-relative path of the plan or coverage file. After a write, that is the path step 5 read back. When an existing file was left unchanged because the user did not ask to update it, the report names that path and says it was left unchanged. The report points at the file. It does not replace the file.

Updates to existing test plans are allowed only when the user explicitly requests an update. That rule does not apply to the first write. Step 5 always creates a missing plan or coverage file.

## Rules

- Language: English.
- Use the templates. Do not invent additional top-level sections.
- Prefer the smallest change. Do not invent Checks that were not present.
- One Check → one test entry (or one clearly bounded assertion group).
- Do not implement production code. Do not execute tests. Do not perform reviews.
- Sequential identifiers are stable. Reuse the source `REQ-`, `TASK-`, or `REF-` ID in the filename. A source with none of those IDs uses the next `TEXT-NNN`.
- One file per source unit, at the path in workflow step 5. The first run creates that file on disk. Updates overwrite the same file and increment `Revision`; no dated or versioned copies.
- A user request to keep the plan in the chat, or to skip saving, does not cancel step 5.

## Output Rules

The file from workflow step 5 contains:
- Source (the resolved `REQ-`, `TASK-`, `REF-`, or `TEXT-NNN` source-id)
- Mode (generate | verify)
- List of Checks with their corresponding test or coverage status
- In verify mode, `Verified inputs` with actual paths and content hashes, plus any limitation that prevents their validation

The user-facing report states the path of that file. The report is not the file.

## Status Handling

This skill does not change task or requirement status. It does not set `blocked`; only the user or the implementing agent does.
If tests are missing that would later be flagged in review, note it in the coverage report. Task documents belong to f-tasks and the implementing agent; do not edit them.

The verify report provides statically inspected coverage evidence for a later review, provided its inputs still match. `f-code-review` validates the recorded hashes without repeating the full coverage assessment and may also use focused inspection of the reviewed diff and relevant tests to establish coverage or a concrete gap. Missing or changed inputs invalidate the report's evidence; without independent direct evidence, use `unverified`. A report's `partial` maps to `unverified` with its documented gap retained. Direct inspection does not refresh the report. A plan alone never establishes coverage, and neither artifact proves a successful test run.

## Templates

All templates live relative to this skill:

- `templates/test-plan.md` — generated test plan
- `templates/coverage-report.md` — coverage check result
- `templates/test-skeleton.md` — optional test skeleton (JavaScript example; adapt to the project's language). A skeleton does not replace the plan or coverage file from step 5.
- `templates/index.md` — tests index (`Source | Mode | Revision | File`)

## Documentation Location

Write every plan and coverage report under `docs/tests/` in the target repository, at the path workflow step 5 resolved.

Follow `references/directory-index.md` whenever creating or updating documentation under `docs/`. Do not change task or requirement status.

## References

- `references/directory-index.md` — shared `index.md` rules. Follow it when writing documentation.
- `references/check-to-test-examples.md` — read when you need concrete mapping patterns.

## Before you finish

- The plan or coverage file is on the filesystem at the resolved path. After a write, a read of that path succeeded and the file is non-empty and contains this run's Source, Mode, and Revision. The final report states that repository-relative path. A plan or report that appears only in the chat is unfinished. When the path already existed and the user did not ask for an update, the report names that file and does not carry a replacement plan.
- Every Check has exactly one test entry (generate) or one explicit status (verify).
- Characterization entries are marked `*(characterization)*` and assert observed behavior, including quirks.
- Every test name references its AC or Check.
- Anything added beyond the Checks is marked `*(supplemented)*`.
- The file follows the naming rule and states source + mode + revision.
- `docs/tests/index.md` lists each plan and coverage file with Source, Mode, Revision, and File. Source is the exact source-id used in the filename.
- Verify reports identify the inspected AC/test inputs and their SHA-256 hashes, or explicitly disclose why those inputs cannot be validated. Test references and coverage gaps are concrete; no test execution is claimed.
- No unfilled `{{...}}` placeholder or `…` filler remains in new or edited sections.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve.
