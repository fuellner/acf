# Changelog

## 2026-10-27
- A refactor or migration plan is a task source: one task per `todo` step, type and order preserved, task id written back to the plan. Recorded bugs are not turned into tasks. A step that is too large is sent back to `f-refactor` instead of being split here.
- The copied directory-index handoff now names the `f-docs` skill and the shared file, matching the Implementation prompt and decision 0003.
- Task template: metadata moved to the bold-line style with hard breaks shared by the other templates; the `Model recommendation` placeholder names the tier + reasoning format; the directory-index paragraph was trimmed to the one sentence the implementing agent needs; the traceability sentence is conditional on the task deriving from a requirement.
- `references/ordering.md`: the conflicts rule names the f-tasks report explicitly instead of an unspecified "the report".

## 2026-10-26
- Ordering and parallel-group rules moved to `references/ordering.md` (workflow step 6).
- Directory indexes follow the shared `references/directory-index.md`. The task template points at that file instead of inlining the procedure.
- `blocked` is set only by the user or the implementing agent. `f-code-review` and `f-debug` may recommend it and must not set it.
- Before finishing, no unfilled `{{...}}` placeholder remains and empty optional sections are removed.
- A requirement still in `draft` is not broken into tasks until the user confirms. The report repeats the warning if work continues. Requirement status is still unchanged.
- `references/complexity-examples.md` is now linked from the complexity section instead of being unreachable.
- Directory index wording aligned with the other skills.
- Separate creation from explicit updates: edit uniquely resolved tasks in place, retain identity/status/authored content and links, and initialize `todo` only for new tasks.
- Require directory indexes for task output, requirement traceability updates, and nested parents below `docs/`. Extend the implementation handoff to rebuild missing indexes and preserve authored content and existing columns.
- Review fixes F-05/F-06: topological ordering takes precedence over priority; open external prerequisites are reported separately.
- Parallel groups require satisfied prerequisites and compatible implementation files/resources. Shared status/index updates use a separate serial handoff, also stated in the task template.
- Clarified cycle detection so shared ancestors on separate dependency paths are not mistaken for cycles.
- `done` now names its actor: `f-code-review` on APPROVED, or explicit user confirmation.
- Task template clarified: implementing agents must not edit requirement documents; the traceability link is written by f-tasks at creation, `Reviews` is appended by the review step.
- Added `changes-requested` to the status model (set by f-code-review).
- On creation, the next ID is derived from the filesystem union index, and existing files are never overwritten.
- Dependencies are now one machine-readable line; `parallel-with` is derived from the graph instead of being stored.
- Added a mandatory acyclic-graph check (chain walk, no script required) and a "Before you finish" self-check.

## 2026-10-25
- Initial creation of f-tasks skill.
- Templates for task documents and index.
- Support for requirements, ad-hoc descriptions, and code-review findings.
- Complexity rating with model/reasoning recommendation.
- Explicit dependencies and parallel-group identification.
- Sequential TASK-IDs, lean index, explicit-only updates.
- Added status tracking (`todo`, `in-progress`, `ready-for-review`, `done`, `blocked`).
  Implementing agent sets at most `ready-for-review`. `done` only after positive review / merge-ready.
- Tasks now back-link to source REQ (Traceability → Related tasks).
