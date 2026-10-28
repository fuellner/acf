# Rollout: {{UNIT_ID}}

**Updated**: {{DATE}}  
**Operator**: {{name or "unknown"}}  
**Notified**: {{who was told before rollout, or "unknown"}}

The agent does not deploy and does not access production.

## Approval

| Action | Needed | Approval |
|--------|--------|----------|
| Deploy or canary | {{yes \| no}} | {{who approved, or "waiting"}} |
| Database migration or backfill | {{yes \| no}} | {{who approved, or "waiting"}} |
| Staging access | {{yes \| no}} | {{who approved, or "waiting"}} |
| Dependency upgrade | {{yes \| no}} | {{who approved, or "waiting"}} |
| Code deletion | {{yes \| no}} | {{who approved, or "waiting"}} |

## Canary

{{slice, image, and how the operator rolls back to the previous image. Or "Not shipping yet."}}

## Signals

Copied from the step records. A firing signal means rollback, not a forward patch.

| Step | Signal | Revert path |
|------|--------|-------------|
{{SIGNAL_ROWS}}

## Result

{{pending \| operator reported success \| rolled back}} — {{evidence from the operator, not from a production session}}
