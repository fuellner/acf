# Changelog

## 2026-10-26
- Directory-index rules now live once in `references/directory-index.md`. Other skills load that file through a symlink in their own `references/` directory. Default columns are `Document | Description`, and `Dokument | Beschreibung` for German human-facing indexes.
- Directory index wording aligned with the other skills: every parent below `docs/` (not `docs/` itself), separate child-directory list, `Dokument | Beschreibung` fallback explicit.
- The `AGENTS.md` self-check names the core sections instead of "critical sections".
- Removed the `docs/.f-docs.json` provenance manifest and its `template_version` bookkeeping: the file had no consumer, duplicated information derivable from the generated files, and went stale immediately.
- README documentation navigation links to each referenced `docs/` subdirectory's `index.md`; standalone files directly under `docs/` remain direct links. Apply the rule to existing links after index generation, update the README template, and bump `template_version` to 3.
- Require generated and maintained documentation subdirectories, including `docs/decisions/` and nested paths, to have current `index.md` files. Repair missing indexes from existing contents while preserving authored prose; do not create empty directories just for indexes.
- Review fix F-03: copy templates only for individually missing target files. Preserve existing free text and project policy even on the first invocation or without provenance metadata.
- Limit placeholder cleanup to generated copies or clear template remnants; report unresolved authored links and policy proposals without deleting content.
- `docs/legal/` is now owned exclusively by f-legal, including its index; f-docs no longer creates the directory or an index.
- Added `templates/index.md` for `docs/legal/index.md`.
- Removed unused frontmatter fields (`type`, `lifecycle`) — OpenCode ignores them.
- Document template carries a binding legal disclaimer; unclear interpretation must be marked `ungeprüft`.
- Added a "Before you finish" self-check.

## 2026-10-25
- Renamed `templates/AGENTS.md` to `templates/agents.md.tmpl`. A file literally named `AGENTS.md` is auto-loaded by agent harnesses as active instructions, so a template with that name was being injected as project policy.
- Added an explicit `TEMPLATE (f-docs)` header block and a removal step after copying.
- Added pruning instructions for placeholders and `Deeper docs` links that do not exist in the target repository.
- Softened the "Never call external APIs" boundary to allow task-required reads of source documents.
- Added `docs/requirements/`, `docs/tasks/`, `docs/tests/` to the deeper-docs index.

## 2026-10-23
- Initial creation of f-docs skill.
