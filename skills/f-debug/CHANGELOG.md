# Changelog

## 2026-10-27
- A failure inside an `f-refactor` unit stays inside that unit's type. Production logs are not read by this skill, and secrets or customer data are not copied into the report.
- Debug-report metadata field renamed from `Date` to `Created`, matching the changelog and the other templates.
- Debug-report placeholders unified to one `UPPER_SNAKE` style; the metadata block gained a `Created`/`Updated` split so the date semantics are unambiguous on revision overwrite, and updates increment `Revision` and update `**Updated**`.
- Fix prompt: the `TASK-ID` placeholder gained the same "or n/a" fallback as the report, severity is defined as the Critical / High / Medium / Low scale shared with `f-code-review`, and the template mirrors f-code-review's `blocked` ownership sentence.
- The template summary in SKILL.md now lists the actual report sections (Metadata, Reproduction, …).

## 2026-10-26
- Reports and prompts always go to `docs/debug/`, including when the failure originated from a review. The review links to the report, and the report links back when exactly one review file resolves. Nothing is written into `docs/reviews/`.
- Directory indexes follow the shared `references/directory-index.md`.
- A `blocked` recommendation names the user or implementing agent as the one who sets the status. This skill still does not change task status. The fix prompt says the same.
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
