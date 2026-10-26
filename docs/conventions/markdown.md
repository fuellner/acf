# Markdown and Skill Conventions

These rules apply to all skill files in this repository.

## Structure

- One skill per directory: `skills/<name>/`.
- Every skill has a `SKILL.md` and a `CHANGELOG.md`; `templates/` and `references/` exist only when they contain files.
- The procedure for `index.md` under `docs/` lives only in `skills/f-docs/references/directory-index.md`. Other skills link that file from `references/directory-index.md` and keep only skill-specific constraints in `SKILL.md`.
- `SKILL.md` starts with YAML frontmatter containing `name` (identical to the directory name) and `description`.
- The description states what the skill does, when to use it, and what it must not be used for.

## Language

- Skill instructions and templates are English.
- `f-legal`, its templates, and generated `docs/legal/` content are German.
- Human-facing repository documents (README, architecture, decisions) are German.

## Templates

- Templates live in `skills/<name>/templates/` and contain placeholders or instructions.
- A template must never be named `AGENTS.md`; use an inert name such as `agents.md.tmpl`.
- Templates are source files. Generated documents belong in the target repository, not in `templates/`.

## Changes

- Update the affected skill's `CHANGELOG.md` for every behavior change.
- Changelog format: `## YYYY-MM-DD` headings, newest first, bullet list of changes.
- Keep changes scoped to one skill unless the change explicitly affects the workflow or a shared contract.
