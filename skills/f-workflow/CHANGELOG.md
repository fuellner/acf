# Changelog

## 2026-10-27
- Implementation prompt points at `docs/tasks/TASK-<id>-<slug>.md` and the exact-ID rule (`TASK-001` matches `TASK-001.md` or `TASK-001-<slug>.md`, not `TASK-0010`). The test-plan placeholder is `TEST-<source-id>-plan.md` for the task and for its Source REQ-ID. Index refresh uses the schema named for that directory.
- `f-refactor` is a separate workflow. The menu only hands off to it and no longer treats it as an optional step of the feature cycle.
- The Implementation prompt still sends an `f-refactor` task to that skill. The task, testing, and review prompts name the refactor handoff.
- Description's do-not list includes migrations and refactors, matching the Optional menu.
- Description's do-not list includes feature summaries, matching the Optional menu.

## 2026-10-26
- Optional menu lists `f-feature-summary` and includes its prompt template.
- Implementation prompt points at the shared directory-index reference (`references/directory-index.md`, owned by `f-docs` and linked from every `f-*` skill) instead of inlining the index procedure.
- Implementation prompt states that the implementing agent sets `blocked` only when a dependency or decision is missing.
- Self-check no longer contradicts the skip-in-menu path: the menu requirement applies only when behavior step 2 did not skip it, and at most one entry is expanded.
- Implementation prompt delegates index rules (explicit parents, separate child-directory list, rebuilding missing indexes) entirely to the shared `references/directory-index.md` instead of restating them.
- Implementation prompt requires current indexes for documentation directories created or updated under `docs/` and that generated links resolve.
- Triggers tightened: the bare word "workflow" no longer matches; only explicit menu/navigation phrases do.
- Implementation prompt now covers the `changes-requested` path.
- Added a "Before you finish" self-check.

## 2026-10-25
- Added explicit **Implementation** step (position 4) between f-testing and f-code-review, including a ready-to-use prompt template. Implementation stays skill-less by design.
- Clarified rules: the core cycle order is fixed and no `f-implement` handle may be invented.

- Initial creation of f-workflow skill.
- Ordered menu separating Core Workflow from Optional / Outside Core (f-docs, f-legal).
- Ready-to-use prompt templates for every skill.
- Navigation-only behavior; no domain work.
