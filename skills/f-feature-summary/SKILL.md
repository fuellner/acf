---
name: f-feature-summary
description: >
  Creates or updates compact, scannable Markdown summaries of implemented
  application features and their business logics (including special cases
  and variants). Prefers tables and structured bullets over prose.
  Supports both individual logical units and an overall overview synthesized
  from them. Use when the user wants a product-owner or stakeholder overview
  of what is implemented, a feature catalog, a scannable summary of current
  functionality, or an update of existing feature documents.
  Triggers on: "feature summary", "product owner overview", "was ist implementiert",
  "feature catalog", "implemented functions", "scannable feature docs",
  "update feature summary", "create feature overview", "summarize implemented logic".
  Do NOT use for technical architecture, requirements writing, general README
  updates, task breakdown, code review, or legal extraction.
---

# Feature Summary

Lightweight, agent-agnostic skill that produces consistent, scannable feature
summaries for product owners and stakeholders. Focuses on implemented behavior
and business logic rather than architecture or requirements.

## Input

Accept any of the following (provided by the user; do not hard-code tool or MCP calls):

- Free-text description of implemented functionality
- Pointer to source code, modules, or existing documentation
- Existing feature documents under `docs/features/` (for updates)
- Explicit request for individual units, overall overview, or both

If the source is referenced but content is missing, ask once. Do not invent features or logic.

## Modes

- **Individual units**: One document per logical unit (feature, module, calculation type, service area, …).
- **Overview**: Single synthesis document built from the individual unit documents.
- **Recommended flow**: Create or update the individual units first, then generate or refresh the overview from them.

Both modes support initial creation and subsequent updates.

## Workflow

1. Clarify scope and mode (individual units, overview, or both). If unclear, default to individuals first, then overview.
2. For individual units:
   - **Create:** collect the IDs from `docs/features/*.md` filenames **and** from `docs/features/index.md` (union of both), take the highest number and add 1. Start at `FEAT-001` when neither exists. Never reuse an ID or overwrite an existing file on creation; check for the same exact ID across both legacy and slugged filenames before writing.
   - **Update:** locate and read the existing document before editing. Use the index as a path hint, then confirm a unique exact-ID match in `docs/features/` (`FEAT-003.md` or `FEAT-003-<slug>.md`, not `FEAT-0030`). If the target is missing or ambiguous, ask for clarification rather than creating a replacement. Keep its ID, filename, Created date, and Status; change Status only per the Status table. Do not allocate a new ID or reapply template defaults.
   - Extract implemented behavior, inputs, core logic, special cases, and outputs from the provided source. Never invent. On update, merge only the requested changes; preserve unrelated sections and authored content.
   - Fill only the sections that contain real content. Remove unfilled placeholders and template HTML comments from new or edited sections. Omit an optional section or metadata line that has no content, including **Hinweise** and **Source** when the user gave none.
   - For creation, write `docs/features/FEAT-<nnn>-<short-slug>.md` using `templates/feature.md` with **Status** `current`. `<nnn>` is the three-digit number (`001` in `FEAT-001`). The template's ID placeholder is that same number, so the heading reads `FEAT-001`. For an update, edit the resolved file in place and update **Updated** when its content changes.
3. For overview:
   - Read all feature documents under `docs/features/` (or the ones explicitly named).
   - Synthesize a compact overview using `templates/overview.md` into `docs/features/overview.md`. Set **Status** to `current` only when every summarized unit is `current`; otherwise use `outdated`, unless the overview was re-verified against the implementation.
   - Prefer linking to the individual documents rather than duplicating detail.
   - On update, merge only the requested changes and preserve authored content that was not requested to change. Apply the Status transitions above. Remove unfilled placeholders, template HTML comments, and empty optional sections (including **Übergreifende Hinweise**).
4. Update `docs/features/index.md` (create from `templates/index.md` if missing) after any change to individual units or to `overview.md`, following `references/directory-index.md`.
5. Report what was created or updated.

Updates to existing documents are allowed when the user explicitly requests an update (e.g. “update FEAT-003”, “refresh the overview”, “add the new special case to the payment feature”).

## Status

| Status | Meaning | Who sets it |
|--------|---------|-------------|
| `current` | The summary matches the implemented behavior it describes | f-feature-summary on creation or after re-verifying the summary against the implementation; user |
| `outdated` | The implementation changed after the summary was last verified | f-feature-summary when it detects drift; user |

Do not invent other values.

## Output Rules

- Language of generated documents: German.
- Use the templates. Do not invent additional top-level sections.
- Prefer tables for conditions, variants, comparisons, or parameter lists.
- Use structured bullets or numbered steps for sequential logic.
- Keep prose to a minimum — one short summary sentence per unit is enough.
- Only include a section when it has real content.
- Sequential IDs are stable.
- Do not implement code. Do not write requirements or architecture docs.

## Templates

All templates live relative to this skill:

- `templates/feature.md` — single logical unit
- `templates/overview.md` — overall synthesis
- `templates/index.md` — feature index

## References

- `references/directory-index.md` — shared `index.md` rules. Follow it when writing documentation.

## Documentation Location

Write all output under `docs/features/` in the target repository.

Follow `references/directory-index.md` whenever creating or updating documentation under `docs/`. Use the features schema (`ID | Title | Status | File`). When `overview.md` exists, add a row for it in that table (ID `—`, file `overview.md`, its Status) so every direct document is listed.

## Before you finish

- No unfilled placeholder or template HTML comment remains in new or edited sections. Empty optional sections were removed.
- Generated text is German. Nothing was invented beyond the provided source.
- Creation used an unused ID and did not overwrite an existing file. An update kept the existing ID, path, Created date, Status (except documented transitions), and unrelated authored content.
- The document exists at the documented path and the index has a matching row.
- Every affected documentation directory and parent below `docs/` has an up-to-date `index.md` per `references/directory-index.md`; entries match existing contents and all generated links resolve.
