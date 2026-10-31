---
name: f-docs
description: Creates or updates project documentation (README, architecture, conventions, decisions) based on repository analysis. Writes AGENTS.md only when none exists and the user agrees; never modifies an existing AGENTS.md. Do not use for legal content, memory files, or non-documentation tasks.
---

# f-docs

Creates or updates project documentation based on repository analysis.

## Purpose

Lightweight, agent-agnostic documentation skill. Analyzes a repository and creates or updates:

- README.md
- docs/architecture.md
- docs/conventions/ (only for detected languages)
- docs/decisions/ (only when decisions are unambiguous)

`AGENTS.md` is optional.

- If the target repository already has an `AGENTS.md`, leave it untouched. Do not ask. Do not create, modify, overwrite, or propose a rewrite.
- If it has none, ask once whether to write one. Write it only after an explicit yes. A decline or no answer yet means it stays absent. Continue with the other documents either way.

`docs/legal/` is **owned by f-legal**. This skill never creates, fills, or updates it.

This skill does not create or fill `MEMORY.md`, `LEARNINGS.md`, or `ERRORS.md`. Those files grow during later work. There is no initial-fill pass.

Templates live in this skill directory and are copied only when the individual target file does not exist. Existing target files are maintained and supplemented, including on the first skill invocation. Templates in the skill directory remain untouched.

On a yes, copy `templates/agents.md.tmpl` byte for byte to the target root as a regular file. The template is deliberately not named `AGENTS.md`: a file with that name is auto-loaded by agent harnesses as active instructions. Do not create a template with that name.

## Behavior

1. Analyze the repository (languages, stack, versions, commands, entry points, existing docs). Check each target file's existence separately.
2. `AGENTS.md`, at the repository root:
   - It exists: stop for this file. Report that it was left unchanged. Do not ask a question about it.
   - It is absent: ask whether to write one. On an explicit yes, copy `templates/agents.md.tmpl` to `AGENTS.md` with the bytes unchanged. Do not add a project, stack, or commands section, do not insert language rules, and do not replace wording with detected values. On no, or while the answer is still open, do not write the file.
3. For each other missing target file: copy the relevant template from the skill's `templates/` directory into the target repository and fill it with analysis results.
   - Replace stack placeholders with the detected values (database, framework, package manager).
   - Remove placeholder sections, boundary lines, and rules that do not apply or contradict the detected stack.
   - Keep only links in `README.md` whose target actually exists in the repository. Drop the link to `AGENTS.md` when that file does not exist.
4. For each existing target file other than `AGENTS.md`, on every invocation including the first: preserve authored free text and project-specific rules. Update or supplement only clearly identifiable structured sections; propose changes to existing project policy or template-driven rewrites instead of silently applying them.
   - Remove markers and placeholders only from new template copies or unambiguous template remnants. Similar-looking authored text is not a reason to delete content.
   - Validate existing links; report broken links that cannot be repaired without changing authored content rather than deleting that content.
5. Only create convention files for languages that are actually detected. Language rules live in those files. `AGENTS.md` only points at `docs/conventions/`.
6. Only create individual decision records when the decision is unambiguous from code or existing docs. An index of existing decisions does not require inventing a new decision.
7. After writing the individual documents, create or refresh `index.md` by following `references/directory-index.md` in every generated or maintained documentation directory under `docs/`, including `docs/conventions/`, `docs/decisions/`, and nested directories. Repair missing indexes in existing convention and decision directories even when no new individual document is needed.
8. Do not create or modify `docs/legal/` — that directory belongs to f-legal. Do not create `docs/implement/` and do not edit implementation logs — `f-implement` owns them. If `docs/implement/` already exists, refresh only its `index.md` using the implement schema in `references/directory-index.md`.
9. Only include sections in generated files when they can be meaningfully filled. Finalize README documentation links after generating directory indexes:
   - Reference documentation in a `docs/` subdirectory through that directory's `index.md`, e.g. `docs/decisions/index.md`. Do not link individual documents inside the subdirectory or the directory path itself from the README; its index is the table of contents.
   - Link standalone documents directly under `docs/`, such as `docs/architecture.md`, directly from the README.
   - Apply this rule to new and existing README documentation links, preserving surrounding authored prose and meaningful descriptions. Use relative links and include only existing targets. If an index is missing, generate it within this skill's scope; for directories owned by another skill, such as `docs/legal/`, report the missing index instead of creating it or falling back to an individual document or directory link.
10. At the end: short report of what was created or updated, which placeholders were filled, and whether `AGENTS.md` was left unchanged, skipped, or copied.

## References

- `references/directory-index.md` — canonical `index.md` rules shared with the other skills.

## Templates

All templates are located in `templates/` relative to this skill:

- `templates/agents.md.tmpl` (copied unchanged as `AGENTS.md`, only on yes, only when missing)
- `templates/readme.md`
- `templates/architecture.md`
- `templates/decision.md`
- `templates/conventions/` (language-specific files only; the index is generated)

## Rules

- Prefer the smallest change that fulfills the requirement.
- Never invent content that cannot be derived from the repository.
- Keep documentation as short and simple as possible while remaining complete enough for humans and agents.
- AGENTS.md and skill instructions are in English. Exception: `f-legal` instructions, its templates, and `docs/legal/` are German; this skill does not create or edit them. Human-facing documents (README, architecture, decisions) are in German. `f-feature-summary` instructions stay English; its templates and `docs/features/` are German.
- Progressive disclosure: AGENTS.md is the short index; deeper docs are linked.

## Before you finish

- An existing `AGENTS.md` is unchanged, and the run did not ask about it.
- When `AGENTS.md` was missing and the user did not agree, it is still absent.
- When `AGENTS.md` was written, it matches `templates/agents.md.tmpl` and has no added section and no unfilled placeholder.
- Newly generated files other than that copy have no template markers or unfilled placeholders. Authored content in pre-existing files is preserved.
- Links created or updated in `README.md` resolve. Any unresolved pre-existing links or proposed policy changes are reported without deleting authored content. The `AGENTS.md` link is omitted when that file does not exist.
- README references to documentation in `docs/` subdirectories target the corresponding `index.md`; standalone files directly under `docs/` are linked directly. No individual subdirectory documents or bare directory paths remain as README documentation links.
- No rule contradicts the detected stack, and no `docs/legal/` content, implementation log, or memory file was written.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve. `docs/legal/` remains excluded.
