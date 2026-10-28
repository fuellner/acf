# Directory indexes

Load this reference when creating or refreshing an `index.md` under `docs/` in a target repository. It is the only copy of these rules. Other skills load it through `references/directory-index.md` in their own skill directory.

## When

Create or refresh `index.md` in each directory the change affects and in every parent below `docs/` (not `docs/` itself), including nested directories.

A file under `docs/legal/` therefore updates that file's directory and `docs/legal/index.md`. `f-docs` does not create or modify `docs/legal/`; `f-legal` does.

`f-docs` does not create `docs/implement/` and does not edit implementation logs; `f-implement` does. An existing `docs/implement/` still gets its `index.md`.

## Contents

- Build a missing index from everything already in that directory, not only the current skill's output. Include documents other skills have written there.
- List every direct document except `index.md`. Do not invent documents.
- Link each child directory through its `index.md` when that file exists. Use a relative link. When the table has no directory column, add those child-directory links as a separate list. For `docs/refactor/`, the File column already points at each unit plan; do not add that second list.
- Use relative links only.
- Refresh generated entries and remove stale ones.
- Preserve authored prose and established columns. The `docs/tests/` and `docs/implement/` column exceptions are stated under Columns.
- Do not create an empty directory just to hold an index.

## Columns

When the index already has columns, keep them. Exception: `docs/tests/` and `docs/implement/` below.

When no format exists yet, use one header pair:

- `Dokument | Beschreibung` for a German human-facing directory. `docs/decisions/` is German. Any other directory whose documents are German uses the same headers.
- `Document | Description` otherwise. `docs/reviews/`, `docs/debug/`, and `docs/implement/` are English. `docs/refactor/` unit directories and `steps/` use this English pair; the `docs/refactor/` index itself uses the schema below. `docs/conventions/` uses this English pair when its documents are English.

These are the same two columns, named in the language of the index. Do not mix the pairs in one file, and do not introduce a third pair.

These schemas replace the two-column default when that index is created:

- Requirements (`docs/requirements/`): `ID | Title | Status | File`
- Tasks (`docs/tasks/`): `ID | Title | Priority | Complexity | Status | File`
- Tests (`docs/tests/`): `Source | Mode | Revision | File`. Source is the exact source-id (`REQ-001` or `TASK-004`). Mode is `generate` for a plan and `verify` for a coverage report. Revision is that document's revision. File is a relative link. One row per file. This schema also replaces an existing table that has only the default `Document | Description` columns; rebuild those rows from the files in the directory and keep authored prose.
- Implement (`docs/implement/`): `Task | Mode | Status | File`. English. One row per implementation log. `Task` is the exact task ID (`TASK-004`). `Mode` is `tdd` or `direct`. `Status` is the task status last recorded in that log. `File` is a relative link to `TASK-<id>-log.md`. This schema also replaces an existing table that has only the default `Document | Description` columns; rebuild those rows from the logs in the directory and keep authored prose.
- Features (`docs/features/`): `ID | Title | Status | File`. The documents are German; this schema still replaces the `Dokument | Beschreibung` default.
- Refactor (`docs/refactor/`): `ID | Title | Type | Priority | Phase | Effort | Status | File`. English. One row per unit. `File` links to that unit's `plan.md`. `Type` is `migration` or `refactor`. `Phase` is the current phase. `Effort` is `S`, `M`, `L`, or `XL`. Do not add a second list of the same unit directories. This index is the cross-unit progress view. Unit subdirectories and `steps/` keep the `Document | Description` default.
- Legal (`docs/legal/`): the columns in the `f-legal` template `templates/index.md` (`Bereich | Dokument | Rechtsgrundlage | Gültig ab | Zuletzt geprüft`)

Skill-specific constraints (who may change a status, whether a directory may be created, serialization of shared updates) stay in the skill that owns them.
