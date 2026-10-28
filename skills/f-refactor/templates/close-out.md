# Close-out: {{UNIT_ID}}

**Type**: {{migration | refactor}}  
**Updated**: {{DATE}}  
**Unit status**: {{status, not done unless a review or the user set it}}

## Evidence

| Criterion | Met | Evidence |
|-----------|-----|----------|
{{CRITERION_ROWS}}

Instruction: for a migration, include rows for the target runtime, the old runtime removed from production, the dependency audit, environment parity, before/after performance of the key pages and jobs, and golden masters diffed on both runtimes. For a refactor, include rows for unchanged behavior, no version bump, and the stated structure. Remove this instruction line.

## Performance

Instruction: omit this section when Type is refactor. Remove this instruction line.

| Page or job | Before | After | Where measured |
|-------------|--------|-------|----------------|
{{PERF_ROWS}}

Numbers come from CI, an approved staging run, or the operator. Not from an agent session on production.

## Parity

Instruction: omit this section when Type is refactor. Remove this instruction line.

{{local and CI checked by the agent; staging and production from an approval or the operator. Or "see inventory.md", plus what was re-checked.}}

## Still open

{{follow-up units, deferred seams, or "None."}}
