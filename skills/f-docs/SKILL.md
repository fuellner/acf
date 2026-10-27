---
name: f-docs
description: Creates or updates project documentation (AGENTS.md, README, architecture, conventions, decisions) based on repository analysis. Use when the user wants documentation generated or refreshed for a repository. Do not use for legal content or for non-documentation tasks.
---

# f-docs

Creates or updates project documentation based on repository analysis.

## Purpose

Lightweight, agent-agnostic documentation skill. Analyzes a repository and creates or updates:

- AGENTS.md (always)
- README.md
- docs/architecture.md
- docs/conventions/ (only for detected languages)
- docs/decisions/ (only when decisions are unambiguous)

`docs/legal/` is **owned by f-legal**. This skill never creates, fills, or updates it.

Templates live in this skill directory and are copied only when the individual target file does not exist. Existing target files are maintained and supplemented, including on the first skill invocation. Templates in the skill directory remain untouched.

`templates/agents.md.tmpl` is deliberately not named `AGENTS.md`: a file named `AGENTS.md` is auto-loaded by agent harnesses as active instructions. Do not create a template with that name.

## Behavior

1. Analyze the repository (languages, stack, versions, commands, entry points, existing docs). Check each target file's existence separately.
2. For each missing target file: copy the relevant template from the skill's `templates/` directory into the target repository and fill it with analysis results.
   - Rename `agents.md.tmpl` to `AGENTS.md`.
   - Remove the `TEMPLATE (f-docs)` comment block from the copied `AGENTS.md` (only this template carries one).
   - Replace stack placeholders with the detected values (database, framework, package manager).
   - Remove placeholder sections, boundary lines, and rules that do not apply or contradict the detected stack.
   - Keep only links in `AGENTS.md` and `README.md` whose target actually exists in the repository.
3. For each existing target file, on every invocation including the first: preserve authored free text and project-specific rules. Update or supplement only clearly identifiable structured sections; propose changes to existing project policy or template-driven rewrites instead of silently applying them. Ensure the core sections of `AGENTS.md` (Project, Stack, Commands, Conventions, Boundaries) are present or report proposed additions.
   - Remove markers and placeholders only from new template copies or unambiguous template remnants. Similar-looking authored text is not a reason to delete content.
   - Validate existing links; report broken links that cannot be repaired without changing authored content rather than deleting that content.
4. Only create convention files for languages that are actually detected.
5. Only create individual decision records when the decision is unambiguous from code or existing docs. An index of existing decisions does not require inventing a new decision.
6. After writing the individual documents, create or refresh `index.md` by following `references/directory-index.md` in every generated or maintained documentation directory under `docs/`, including `docs/conventions/`, `docs/decisions/`, and nested directories. Repair missing indexes in existing convention and decision directories even when no new individual document is needed.
7. Do not create or modify `docs/legal/` — that directory belongs to f-legal.
8. Only include sections in generated files when they can be meaningfully filled. Finalize README documentation links after generating directory indexes:
   - Reference documentation in a `docs/` subdirectory through that directory's `index.md`, e.g. `docs/decisions/index.md`. Do not link individual documents inside the subdirectory or the directory path itself from the README; its index is the table of contents.
   - Link standalone documents directly under `docs/`, such as `docs/architecture.md`, directly from the README.
   - Apply this rule to new and existing README documentation links, preserving surrounding authored prose and meaningful descriptions. Use relative links and include only existing targets. If an index is missing, generate it within this skill's scope; for directories owned by another skill, such as `docs/legal/`, report the missing index instead of creating it or falling back to an individual document or directory link.
9. At the end: short report of what was created or updated, and which placeholders were filled.

## References

- `references/directory-index.md` — canonical `index.md` rules shared with the other skills.

## Templates

All templates are located in `templates/` relative to this skill:

- `templates/agents.md.tmpl` (copied as `AGENTS.md`)
- `templates/readme.md`
- `templates/architecture.md`
- `templates/decision.md`
- `templates/conventions/` (language-specific files only; the index is generated)

## Rules

- Prefer the smallest change that fulfills the requirement.
- Never invent content that cannot be derived from the repository.
- Keep documentation as short and simple as possible while remaining complete enough for humans and agents.
- AGENTS.md and skill instructions are in English. Human-facing documents (README, architecture, decisions) are in German.
- Progressive disclosure: AGENTS.md is the short index; deeper docs are linked.

## Before you finish

- `AGENTS.md` exists. Newly generated files have no template markers or unfilled placeholders; authored content in pre-existing files is preserved.
- Links created or updated in `AGENTS.md` and `README.md` resolve. Any unresolved pre-existing links or proposed policy changes are reported without deleting authored content.
- README references to documentation in `docs/` subdirectories target the corresponding `index.md`; standalone files directly under `docs/` are linked directly. No individual subdirectory documents or bare directory paths remain as README documentation links.
- No rule contradicts the detected stack, and no `docs/legal/` content was written.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve. `docs/legal/` remains excluded.
