# Changelog

## 2026-10-28
- `references/directory-index.md` names the `docs/implement/` schema (`Task | Mode | Status | File`). `f-docs` does not create that directory and does not edit implementation logs.
- The deeper-docs template lists `docs/implement/` so the link is kept when that directory exists.

## 2026-10-27
- Language rule names the `f-legal` exception: its instructions, templates, and `docs/legal/` stay German, and this skill does not edit them. `f-feature-summary` instructions stay English.
- `docs/tests/` index schema is `Source | Mode | Revision | File`. A default `Document | Description` table in that directory is replaced by this schema.
- Named the `docs/refactor/` index schema (`ID | Title | Type | Priority | Phase | Effort | Status | File`) in `references/directory-index.md`. The File column is the child-directory entry, so that index does not also list the unit directories. Unit and `steps/` directories stay on `Document | Description`. The index is the cross-unit progress view.
- Deeper-docs template lists `docs/refactor/` so the link is kept when that directory exists.
- Changelog corrections: the stale `template_version` reference and the misplaced legal index template attribution (that template lives in `f-legal`) were fixed.
- The copy step now reflects that only `agents.md.tmpl` carries a `TEMPLATE (f-docs)` block.
- `agents.md.tmpl`: the two overlapping drive-by/refactor bullets were merged into one.
- readme template fully German ("Technologie-Stack", "Konventionen" instead of English headings and link text).

## 2026-10-26
- Named the `docs/features/` index schema (`ID | Title | Status | File`) in `references/directory-index.md`.
- Deeper-docs template lists `docs/features/` so the link is kept when that directory exists.
- Directory-index rules now live once in `references/directory-index.md`. Other skills load that file through a symlink in their own `references/` directory. Default columns are `Document | Description`, and `Dokument | Beschreibung` for German human-facing indexes.
- Directory index wording aligned with the other skills: every parent below `docs/` (not `docs/` itself), separate child-directory list, `Dokument | Beschreibung` fallback explicit.
- The `AGENTS.md` self-check names the core sections instead of "critical sections".
- Removed the `docs/.f-docs.json` provenance manifest and its `template_version` bookkeeping: the file had no consumer, duplicated information derivable from the generated files, and went stale immediately.
- README documentation navigation links to each referenced `docs/` subdirectory's `index.md`; standalone files directly under `docs/` remain direct links. Apply the rule to existing links after index generation and update the README template.
- Require generated and maintained documentation subdirectories, including `docs/decisions/` and nested paths, to have current `index.md` files. Repair missing indexes from existing contents while preserving authored prose; do not create empty directories just for indexes.
- Review fix F-03: copy templates only for individually missing target files. Preserve existing free text and project policy even on the first invocation or without provenance metadata.
- Limit placeholder cleanup to generated copies or clear template remnants; report unresolved authored links and policy proposals without deleting content.
- `docs/legal/` is now owned exclusively by f-legal, including its index; f-docs no longer creates the directory or an index.
- Added `templates/index.md` in `f-legal` for `docs/legal/index.md`.
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
