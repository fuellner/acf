# TASK-{{ID}}: {{TITLE}}

- **Source**: {{SOURCE}}
- **Priority**: {{PRIORITY}}
- **Complexity**: {{COMPLEXITY}}
- **Model recommendation**: {{MODEL}}
- **Dependencies**: {{DEPENDENCIES}}
- **Status**: todo
- **Created**: {{CREATED}}
- **Updated**: {{UPDATED}}

## Goal
{{GOAL}}

## Acceptance Criteria
{{ACCEPTANCE_CRITERIA}}

## Files to touch
{{FILES_TO_TOUCH}}

## Files not to touch
{{FILES_NOT_TO_TOUCH}}

## Verification
{{VERIFICATION}}

## After implementation
When finished and local verification passed:
- Set **Status** to `ready-for-review`
- Update **Updated**
- Update the corresponding row in `docs/tasks/index.md`

For documentation created or updated under `docs/`, create or refresh `index.md` in every affected directory and each parent below `docs/`, including nested directories. Rebuild missing indexes from all existing contents, using relative links to direct documents (excluding the index itself) and child directories. Preserve authored prose and established columns; task indexes use `ID | Title | Priority | Complexity | Status | File`. Remove stale generated entries and check that links resolve.

For parallel implementations, use the agreed serial handoff for shared status/index updates. Read the latest index before updating your row and preserve other agents' entries.

Do not set `done` — `f-code-review` sets it after an APPROVED verdict, or the user confirms it.
Do not edit requirement documents. The traceability link was added by `f-tasks` at creation time; `f-code-review` owns requirement completion and review links.

## Notes
{{NOTES}}
