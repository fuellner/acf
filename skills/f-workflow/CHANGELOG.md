# Changelog

## 2026-10-26
- Implementation prompt points at the shared directory-index reference (`references/directory-index.md`, owned by `f-docs` and linked from every `f-*` skill) instead of inlining the index procedure.
- Implementation prompt states that the implementing agent sets `blocked` only when a dependency or decision is missing.
- Self-check no longer contradicts the skip-in-menu path: the menu requirement applies only when behavior step 2 did not skip it, and at most one entry is expanded.
- Implementation prompt and index rule aligned with the other skills (explicit parents, separate child-directory list).
- Implementation prompt requires current indexes for affected documentation directories and parents below `docs/`, including rebuilding missing indexes from existing contents.
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
