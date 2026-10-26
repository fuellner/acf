# Changelog

## 2026-10-26
- Debug reports carry a revision counter: re-analysis of the same unit overwrites the file and increments `Revision` instead of adding version suffixes.
- Directory index rule aligned with the other skills (explicit parents, separate child-directory list).
- Maintain directory indexes for saved reports and prompts, including nested paths and shared `docs/reviews/` contents. Clarify that documentation output is allowed while investigation stays read-only.
- Fix prompt moved to `templates/fix-prompt.md` field names shared with f-code-review (Findings / Out of scope / Verification / Status handoff).
- Review-originated reports now go to `docs/reviews/` instead of a root-level `reviews/`.
- Added a "Before you finish" self-check.

## 2026-10-25
- Resolved contradiction between "Reproduce" and "do not run tests": read-only reproduction (failing test, replay command, log inspection) is now explicitly allowed and expected.
- Rules reworded to "read-only only": no code, config, or data changes; no state-changing commands; no status updates.
- Frontmatter description no longer lists "running tests" as out of scope; "acting as a test runner" clarifies the intent.

- Initial creation of f-debug skill.
