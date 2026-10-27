# Changelog

## 2026-10-27
- Given/When/Then is required for behavioral criteria; the self-check now matches the body, with `Check` and `Must not` required for every criterion.
- Requirement `done` accepts CONCERN criteria with review evidence, matching `f-code-review`.
- Every acceptance criterion must now carry an `AC-n` identifier so f-testing and f-code-review can reference it.
- The one-observable-result rule now permits tightly coupled side conditions of the same action, matching the bundled examples.
- Template metadata uses the bold-line style with hard breaks, shared with the other skills' templates.

## 2026-10-26
- Directory indexes follow the shared `references/directory-index.md`.
- Noted that `f-tasks` asks before deriving tasks while a requirement is `draft` and still must not change requirement status.
- Automatic traceability writes by `f-tasks` (`Related tasks`) and `f-code-review` (`Reviews`, status) are now explicit exceptions to the explicit-update-only rule.
- The requirement template defines `Traceability` with `Related tasks` and `Reviews` subsections, matching what the other skills write into.
- Directory index wording aligned with the other skills.
- Separate creation from explicit updates: resolve existing requirements by exact ID, edit in place, preserve identity/status/authored content and links, and refresh Updated and the index.
- Require current directory indexes for every affected path and parent below `docs/`, including nested directories. Rebuild missing indexes from existing contents, preserve authored prose, and validate relative links.
- On creation, the next ID is derived from the filesystem union index, and existing files are never overwritten.
- Added a status model (`draft`, `approved`, `done`, `obsolete`) with explicit actors.
- Template: `Status` defaults to `draft`.
- Added a "Before you finish" self-check.

## 2026-10-25
- Initial creation of f-requirements skill.
- Templates for requirement documents and index.
- Strict acceptance criteria format with supplementation marking.
- Sequential REQ-IDs, lean index, explicit-only updates.
