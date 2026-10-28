# {{UNIT_ID}}: {{TITLE}}

**Type**: {{migration | refactor}}  
**Status**: draft  
**Phase**: {{inventory \| prioritize \| safety-net \| plan \| execute \| rollout \| close-out}}  
**Priority**: {{P0 | P1 | P2 | P3}}  
**Effort**: {{S \| M \| L \| XL}}  
**Target**: {{target runtime or framework, or "current runtime"}}  
**Source**: {{user request}}  
**Created**: {{DATE}}  
**Updated**: {{DATE}}

## Scope
{{SCOPE}}

## Non-goals
{{NON_GOALS}}

## Done criteria
{{DONE_CRITERIA}}

Each step record names a revert path and the production signal that triggers it. A migration also requires environment parity and before/after performance of the key pages and jobs in the inventory.

## Current state
- Inventory: [inventory.md](inventory.md)
- Codebase map: [codebase-map.md](codebase-map.md)
Instruction: add a link for safety-net.md, rollout.md, or close-out.md only after that file exists. Remove this instruction line.

{{CURRENT_STATE}}

## Strategy
{{STRATEGY}}

## Effort basis
{{one sentence. S is one or two steps, M a handful, L several modules or hops, XL must be split.}}

## Team

- Reviewer / approver: {{name or "unknown"}}
- Operator: {{name or "unknown"}}
- Notify before rollout: {{names or "unknown"}}

## Parallel work
{{per-module freeze window, or the rebase rule for feature branches, or a question if the team has not chosen}}

## Cross-repo dependencies

| Depends on | Kind | Blocks | Known status |
|------------|------|--------|--------------|
{{DEP_ROWS}}

A row may name another `REF` id or another repository. Status is `unknown` when that repository was not read. Use "none" when there is no dependency.

## Interim risk mitigation
Instruction: omit this whole section when Type is refactor, and remove this instruction line when the section stays.

These are stopgaps while an unsupported runtime remains in production. They do not satisfy the done criteria.

{{MITIGATIONS}}

## Steps

| Step | Title | Status | Task | Record |
|------|-------|--------|------|--------|
{{STEP_ROWS}}

## Follow-ups
{{FOLLOW_UPS}}

## Recorded bugs
{{RECORDED_BUGS}}

## Notes
{{NOTES}}
