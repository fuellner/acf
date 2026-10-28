# TASK-{{ID}}: {{TITLE}}

**Source**: {{SOURCE}}  
**Ticket**: {{TICKET}}  
**Priority**: {{PRIORITY}}  
**Complexity**: {{COMPLEXITY}}  
**Model recommendation**: {{MODEL (tier + reasoning level)}}  
**Dependencies**: {{DEPENDENCIES}}  
**Status**: todo  
**Created**: {{CREATED}}  
**Updated**: {{UPDATED}}

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

For documentation created or updated under `docs/`, refresh `index.md` by following `references/directory-index.md` in the installed `f-docs` skill. Every installed `f-*` skill links the same file at `references/directory-index.md`. Use that directory's schema from that file (for `docs/tasks/`, the tasks schema) and check that the links resolve.

For parallel implementations, use the agreed serial handoff for shared status/index updates. Read the latest index before updating your row and preserve other agents' entries.

Do not set `done` — `f-code-review` sets it after an APPROVED verdict, or the user confirms it.
Set `blocked` only when you cannot proceed because a dependency or decision is missing, and record what unblocks the task. `f-code-review` and `f-debug` may recommend `blocked` and must not set it.
Do not edit requirement documents. When the task derives from a requirement, its traceability link was added by `f-tasks` at creation time; `f-code-review` owns requirement completion and review links.

## Notes
{{NOTES}}
