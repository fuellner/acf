---
name: f-debug
description: Conduct a structured, evidence-based debugging process (Reproduce → Isolate Root Cause → Propose Minimal Fix → Verify). Use when investigating a bug, failing test, stack trace, unexpected error, or log anomaly before any code change. Trigger on "debug this", "find root cause", "why is this failing", "reproduce the error", "analyze this failure". Do not use for implementing fixes, writing production code, acting as a test runner, full code reviews, or general refactoring.
---

# f-debug

Structured, evidence-based debugging analysis. Prevents thrashing and scope creep. Produces a Debug Report and optional Fix Prompt. Does **not** implement code. Read-only reproduction (running the failing test, replaying the command, inspecting logs) is explicitly in scope.

## Purpose

Guide an agent through a minimal, one-pass debugging process so that a subsequent implementing agent receives a precise, evidence-backed fix proposal instead of open-ended exploration.

## Input

Accept any of:
- Error description, stack trace, or log excerpt
- Failing test name or output
- Task ID (TASK-xxx) and/or Requirement ID (REQ-xxx) if known
- Relevant diff, file paths, or code snippets
- Reproduction steps (or a statement that they are unknown)

If critical information is missing (especially reproduction steps or concrete evidence), stop and request it. Do not guess.

## Workflow

Follow these phases in order. Complete each before moving to the next. Stop and ask if evidence is insufficient.

1. **Reproduce**
   - Confirm whether the failure is reproducible. Run the failing test or replay the reported command if read-only; do not change code, data, or configuration to make it reproduce.
   - Record exact steps, environment assumptions, and observed vs. expected behavior.
   - If not reproducible with the given information, state what is missing and request it. Do not proceed to root-cause claims.

2. **Isolate Root Cause**
   - Identify the precise location and mechanism of the failure using the provided evidence (stack frames, log lines, test assertions, code paths).
   - Cite concrete evidence. Avoid speculation. If multiple plausible causes exist, list them ranked by evidence strength and note what would distinguish them.
   - Prefer the smallest explanatory scope.

3. **Propose Minimal Fix**
   - Suggest the smallest change that addresses the isolated root cause.
   - Explicitly state what is out of scope (no drive-by refactors, no new features, no broader cleanup).
   - Reference the Task/Requirement IDs if known.

4. **Verify**
   - Define concrete verification steps the implementing agent should perform (e.g., specific test to re-run, log check, reproduction steps that must now pass).
   - State the expected outcome of verification.

## Rules

- One pass only. Do not iterate on your own analysis within this skill.
- Minimal scope: change only what is necessary to fix the isolated cause.
- No inventions: every claim must be tied to provided evidence or an explicit request for missing evidence.
- Reproduction and investigation are read-only: you may run the failing test, reproduction command, and log/grep inspection. Never modify code, config, or application data, never run commands that change application state (migrations, writes, installs that alter the repo), and never update task status. Writing the report, fix prompt, and directory indexes described below is allowed.
- Clear boundaries:
  - This skill = analysis + proposal.
  - Implementing agent = applies the fix and runs verification.
  - f-code-review = later review of the resulting change.

## Output

Produce a Debug Report using the template at `templates/debug-report.md`.

Optionally (and by default when a fix is proposed) also produce a short Fix Prompt using `templates/fix-prompt.md`. The Fix Prompt is written for the implementing agent and should be copy-paste ready.

Save the report (and prompt) under `docs/reviews/` when the failure originated from a review finding, otherwise under `docs/debug/`, with a filename that includes the Task ID when available, e.g. `docs/debug/TASK-042-debug.md`. Create the directory only if needed. On an explicit re-analysis of the same unit, overwrite the same file and increment `Revision` inside it; do not add version suffixes — Git is the history.

Whenever saving documentation under `docs/`, create or refresh `index.md` in each affected directory and every parent below `docs/` (not `docs/` itself), including nested directories. Build missing indexes from all existing contents, including reports from other skills. List direct documents except the index itself and link child directories through their `index.md` when present, using relative links. Refresh generated entries and remove stale ones while preserving authored prose and established columns; use `Document | Description` when no format exists. Add child-directory links as a separate list if needed. Do not create empty directories just for indexes.

## Status Handling

- If the failure cannot be reproduced or critical evidence is missing: recommend setting the related task to `blocked` and list the exact information required.
- After a complete analysis with a proposed fix: leave the task status as-is (typically `in-progress`) and note that the implementing agent should apply the fix then set status to `ready-for-review`.
- Do not change task status yourself. Only recommend.

## Templates and References

- `templates/debug-report.md` — structured report (Problem, Evidence, Root Cause, Proposed Fix, Verification).
- `templates/fix-prompt.md` — short, focused prompt for the implementing agent.
- `references/debugging-notes.md` — optional lightweight heuristics (load only if the failure type is unusual).

Read the templates before generating output. Keep generated reports concise.

## Before you finish

- Every claim cites concrete evidence (frame, log line, assertion, code location); hypotheses are labelled as such.
- The root cause is the smallest explanation consistent with that evidence.
- The proposed fix is minimal and names what is out of scope.
- Verification steps are executable and state the expected outcome.
- No code, configuration, application data, or task status was modified.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md`; entries match existing contents and all generated links resolve.
