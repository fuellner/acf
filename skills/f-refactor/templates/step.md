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

The agent does not roll this step back in production. The operator does.

### Revert path
- Code: {{revert commit or previous image}}
- Flag: {{flag to turn off, or "no flag"}}
- Database: {{how the expand is safe to leave, or the contract reversal. "No schema change" when none.}}

### Production signals
{{error rate, log pattern, or golden-master mismatch that means roll back. Not a threshold invented without the operator.}}

## Follow-ups
{{new units or later steps, or "None."}}
