# {{STEP_ID}}: {{TITLE}}

**Plan**: {{UNIT_ID}}  
**Type**: {{migration | refactor}}  
**Status**: {{STATUS}}  
**Task**: {{TASK_ID or "none"}}  
**Created**: {{DATE}}  
**Updated**: {{DATE}}

## Intent
{{one sentence}}

## Changes
{{what changed and which paths, or "none — blocked"}}

## Forced or optional

### Forced
{{fixes the upgrade requires, or "None — refactor at the current runtime."}}

### Not forced
{{must be "None." on a migration. On a refactor, the structural change.}}

## Verification

| Command | Runtime | Result |
|---------|---------|--------|
{{VERIFICATION_ROWS}}

**Commits / PRs**: {{hashes or URLs}}

## Behavior
{{unchanged, or the forced exception. State whether any assertion was edited.}}

## Recorded bugs
{{bugs observed and not fixed, or "None."}}

## Rollback
{{how to revert this step alone}}

## Follow-ups
{{new units or later steps, or "None."}}
