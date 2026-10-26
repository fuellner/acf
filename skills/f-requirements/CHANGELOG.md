# Changelog

## 2026-10-26
- Automatic traceability writes by `f-tasks` (`Related tasks`) and `f-code-review` (`Reviews`, status) are now explicit exceptions to the explicit-update-only rule.
- The requirement template defines `Traceability` with `Related tasks` and `Reviews` subsections, matching what the other skills write into.
- Directory index wording aligned with the other skills.
- Separate creation from explicit updates: resolve existing requirements by exact ID, edit in place, preserve identity/status/authored content and links, and refresh Updated and the index.
- Require current directory indexes for every affected path and parent below `docs/`, including nested directories. Rebuild missing indexes from existing contents, preserve authored prose, and validate relative links.
- On creation, the next ID is derived from the filesystem union index, and existing files are never overwritten.
- Added a status model (`draft`, `approved`, `done`, `obsolete`) with explicit actors.
- Template: `Status` defaults to `draft`; traceability is a single placeholder so the section can be dropped when empty.
- Added a "Before you finish" self-check.

## 2026-10-25
- Initial creation of f-requirements skill.
- Templates for requirement documents and index.
- Strict acceptance criteria format with supplementation marking.
- Sequential REQ-IDs, lean index, explicit-only updates.
