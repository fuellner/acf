---
name: f-code-review
description: >
  Compares code changes from a commit or branch diff against requirements and acceptance criteria,
  then checks for security issues, performance problems, and unwanted side effects.
  Delivers precise, actionable findings with location, evidence, and a concrete fix suggestion,
  plus a ready-to-use fix prompt. Keeps output short and avoids review-fix loops.
  Use when the user asks to review a commit, PR, branch, or local changes against acceptance criteria,
  check whether requirements are fulfilled, or review for security, performance, or side effects.
  Triggers on: "review this commit", "check branch against ACs", "code review", "prüfe die Änderungen",
  "does this fulfill the requirements", "security review", "performance review".
  Do NOT use for style or linting only, writing new code, debugging runtime errors, or automated CI checks.
---

# Code Review

Lightweight, agent-agnostic review of a change against its requirements.
One pass per invocation. No code edits. No automatic re-review.
Documentation changes are limited to review reports and the Status Propagation section below.

## Input

1. Obtain the diff:
   - Commit: `git show <commit>` (or equivalent)
   - Branch: `git diff <base>...HEAD` (default base: main)
   - Local: staged + unstaged

2. Identify requirements / acceptance criteria (in this order):
   - Explicit list or description in the current user message
   - Linked issue, ticket, or PR description (if a number/URL is given)
   - `docs/requirements/REQ-*.md` — pick the file matching the given REQ-ID or the change's scope
   - Other project files such as `ACCEPTANCE.md` or `requirements.md` in the repo root or `docs/`
   - Commit message or PR title/body if it clearly states the intent

   If none of these provide clear, testable criteria, ask the user once for them.  
   Do not invent or assume acceptance criteria.

3. When a test plan or coverage report exists for the source (`docs/tests/TEST-<source-id>-plan.md`, `-coverage.md`), read `references/coverage-evidence.md` before using it. Apply that reference when deciding whether the report is current evidence and when assigning `covered`, `missing`, or `unverified`. Do not refresh the report or perform a full coverage audit.

4. For an explicit re-review, load the previous report for the same unit or the previous findings supplied by the user. If the request refers to prior findings that are unavailable, ask once for them before issuing a verdict. Do not infer that they were resolved.

## Review Sequence

### Stage 1 — Spec Compliance (blocking)

For each acceptance criterion or stated requirement:

- Locate the implementing code in the diff.
- Confirm it fulfills the criterion exactly (not more, not less).
- State test coverage as `covered`, `missing`, or `unverified` by applying `references/coverage-evidence.md`. Cite the evidence used for each state.

Verdict per criterion: **PASS** | **FAIL** | **CONCERN** (met, but with a documented residual risk that needs attention).
Flag anything built beyond the stated requirements as **OVER-BUILT**.

If any criterion is FAIL → overall verdict is **CHANGES REQUIRED**. Continue only for information.
Any open Critical/High finding also requires **CHANGES REQUIRED**, including a previous blocker whose resolution cannot be established. Never propagate `done` while such a blocker remains.

### Stage 2 — Safety Checks

Only report concrete issues with evidence. Ignore pure style.
For additional checklist detail see `references/safety-checks.md`.

**Security**
- Injection (SQL, command, template, etc.)
- Missing or weak authorization / authentication checks
- Secrets or credentials in code or logs
- Unsafe deserialization or user-controlled input reaching sensitive sinks
- Missing validation at system boundaries

**Performance**
- Obvious N+1 queries or unbounded loops
- Expensive work on hot paths without limits or caching where expected
- Large allocations or blocking calls that scale poorly

**Unwanted side effects**
- Changes that alter behavior of existing paths outside the stated scope
- Breaking changes to public APIs, contracts, or data formats without migration
- Unintended state mutations or race conditions
- Dead code or speculative features introduced by the change

## Output Rules

- Be precise. Every finding must include file:line (or closest range), the problem, evidence, and a concrete fix suggestion.
- No filler, no style nits, no generic advice.
- Maximum one pass per invocation. Do not edit code or automatically start another review.
- On explicit re-review requests, assess the new diff and verify every previously open finding against the current code. Carry unresolved findings forward; summarize resolved findings briefly with evidence. Search for additional issues only in the new diff and its effects.
- Keep unresolved findings in the Findings section. Include only open findings in the fix prompt; resolved findings need only a short resolution note in Findings. When none remain, state that no fix prompt is needed.

## Output Template

Always produce exactly this structure:

````markdown
# Code Review

**Target**: <commit or branch>
**Revision**: N
**Verdict**: APPROVED | CHANGES REQUIRED
**Spec Compliance**: PASS | FAIL

## Acceptance Criteria
- <criterion>: PASS | FAIL | CONCERN — <one-line note> [test: covered | missing | unverified]

## Findings
1. **High** [open] – `path/to/file.ts:42`
   Problem: …
   Evidence: …
   Fix: …

(On re-review, also summarize resolved findings with evidence. Use "None" if there are no findings.)

## Residual Risk
- …

## Fix-Prompt
```prompt
Apply only the following open findings. Keep changes minimal; do not expand scope or re-architect.

**Findings:**
1. [High] path/to/file.ts:42 — Problem: … — Proposed fix: …

**Out of scope:**
- Refactors, renames, or style changes not required by a finding.

**Verification you must perform:**
- Run the tests named in the findings or the relevant suite.
- Confirm each finding is resolved; do not review the result yourself.

**Status handoff:**
- Task `TASK-xxx`: set `in-progress` when you start, `ready-for-review` when done. Do not set `done`. Set `blocked` only when you cannot proceed because a dependency or decision is missing, and record what unblocks the task.
```
````

## Status Propagation

Documentation only — never code. Update only task and requirement documents referenced by this review, plus directory indexes per `references/directory-index.md`.

Resolve a referenced TASK-ID before changing anything:
- Use `docs/tasks/index.md` as a path hint and validate it against the filesystem. Match the exact ID: both `TASK-001.md` and `TASK-001-<slug>.md` are valid; `TASK-0010` is not a match for `TASK-001`.
- Check `docs/tasks/` for all exact-ID matches, including when an index hint exists, so duplicate files cannot be hidden by the index. A missing or stale index does not prevent a unique filesystem match.
- With no matching file, skip the task updates and mention the missing document once in the report. With multiple matches, change none of them and report the ambiguity.
- Use the uniquely resolved path for all task status, date, Notes, and index updates. The report filename still uses the TASK-ID.

**Verdict APPROVED and every criterion PASS:**
- Set the task **Status** to `done` and update its **Updated** field.
- Update the corresponding row in `docs/tasks/index.md`.
- If a report was written, append its path under the task's `Notes`.
- If a requirement is linked, set its **Status** to `done` **only when every criterion of the entire requirement passes**. Approval of one partial task is insufficient.
- Whenever setting a requirement to `done`, update its **Updated** field and synchronize its row in `docs/requirements/index.md` in the same operation. Preserve its ID, title, and actual file path. If that index is missing, rebuild it from existing requirement documents using the requirements schema in `references/directory-index.md`; do not invent entries.
- Append the review path under `Traceability → Reviews` only when a report was written.

**Verdict CHANGES REQUIRED:**
- Set the task **Status** to `changes-requested`, update **Updated**, and update the tasks index row.
- Append the review path under the task's `Notes` when a report was written.
- The fix prompt is the handoff; the implementing agent moves the task to `in-progress`, then back to `ready-for-review`.

**Requirement documents:** apply requirement updates only to an existing, unambiguously linked requirement. Append the review file path under `Traceability → Reviews` when a report was written. On CHANGES REQUIRED the requirement **Status** and its index status stay unchanged.

Never set `blocked` or `obsolete`. Only the user or the implementing agent sets `blocked`. This skill may recommend `blocked` in the report and must not apply that recommendation. Never change task or requirement documents outside this review. Directory indexes may list those existing documents without modifying them. If a referenced document does not exist, skip its updates and mention it once in the report.

## Documentation

Write the full review report to `docs/reviews/<TASK-ID>-review.md` when:
- The verdict is **CHANGES REQUIRED**, or
- The user explicitly asks to document / save the review (e.g. "documentiere das Review", "speichere das Ergebnis", "write the review report").

After a fix has been applied and the user requests a note, write a short `docs/reviews/<TASK-ID>-fix.md` describing what changed and why.

Keep both files minimal. Do not create them for clean APPROVED reviews unless the user asks.

Debug reports are not review output. They live in `docs/debug/`. When `docs/debug/<unit>-debug.md` exists for the reviewed unit, add a `Debug:` bullet under `## Residual Risk` that links to it with a relative path (`../debug/<unit>-debug.md` from `docs/reviews/`), unless that link is already present. Do not copy the debug report into `docs/reviews/`.

Follow `references/directory-index.md` whenever writing a report, fix note, or task/requirement update under `docs/`. On CHANGES REQUIRED, preserve requirement **Status** values already stored in the requirement index. Do not create `docs/reviews/` or its index for an unsaved review.

## File Naming

- Use the reviewed unit, in this order: `TASK-ID` → `REQ-ID` → branch slug. Never name a file after the reviewer or the date.
- No date or version suffixes — Git is the history. Add `**Revision**: N` inside the report and increment it on a repeat review of the same unit.
- On a repeat review, reuse the same filename. Only add `-r2`, `-r3`, … when the user wants the previous report preserved.
- Read the previous report before replacing it. Carry every still-open finding into the new revision, with brief resolution notes for findings closed in this invocation.

## Templates

- `templates/fix-prompt.md` — canonical handoff prompt for the implementing agent. Same field names as the f-debug fix prompt: Findings / Out of scope / Verification / Status handoff.

## References

- `references/coverage-evidence.md` — load before using a test plan or coverage report, and when assigning a coverage state.
- `references/directory-index.md` — shared `index.md` rules.
- `references/safety-checks.md` — extra Stage 2 checklist detail.

## Before you finish

- Every criterion has a verdict (PASS | FAIL | CONCERN), and the overall verdict is consistent with them and with any open findings.
- Every coverage state follows `references/coverage-evidence.md`. No test execution is claimed without evidence.
- Previous findings were checked on explicit re-review; all unresolved blockers remain in the report and prevent APPROVED or `done`.
- Every finding names a severity, a file:line, evidence, and a fix.
- The fix prompt contains only open findings, never resolved findings or extra scope.
- Status updates were applied to the referenced documents only, and only as described above.
- Task paths were resolved uniquely by exact ID. After a requirement status change, its document and index agree and its Updated field is current.
- A debug report for this unit is linked from the review when one exists, and was not copied into `docs/reviews/`.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve. No review directory was created for an unsaved review.

## Severity

- **Critical / High**: blocks merge (security, correctness, broken AC, major side effect)
- **Medium**: should be fixed soon
- **Low**: optional, only mention if clearly valuable

Do not invent severity. Prefer fewer, higher-signal findings.
