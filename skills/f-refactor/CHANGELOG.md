# Changelog

## 2026-10-27
- `f-refactor` is a separate workflow with its own phase menu, parallel to `f-workflow`. It reuses `f-tasks`, `f-testing`, `f-code-review`, `f-debug`, and `f-docs`.
- Index columns gain Phase and Effort. The index is the cross-unit progress view.
- Guardrails: production access is off-limits; database migrations, staging, dependency upgrades, deletions, and deploys need human approval.
- Inventory records non-web entry points and environment parity. Steps record a revert path and the production signal that triggers rollback. Close-out records performance before and after.
- Golden masters normalize nondeterministic fields, ban production data, and may not be refreshed without a written reason.
- Initial creation of f-refactor.
- One skill, two required unit types: `migration` (primary) and `refactor`. Behavior stays the same; bugs are recorded, not fixed; each step is releasable on its own.
- Artifacts under `docs/refactor/REF-<id>-<slug>/` so a later session can resume without chat history.
- References for PHP version upgrades, large legacy codebases, structural strategies, PHP tools, database expand/contract, and characterization tests.
