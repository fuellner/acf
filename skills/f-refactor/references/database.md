# Database changes

Load when a step touches schema or stored data. The application stays in production through rolling releases, so old and new code run at the same time.

## Expand, then contract

1. **Expand** — add the new shape beside the old one (nullable column, new table, new write that the old code ignores). Ship it. Do not drop, rename, or tighten a constraint in this release.
2. **Backfill** — batched, resumable, and idempotent. Both code versions must be correct while the backfill is partial. Record how to restart it.
3. **Switch** — new code reads the new shape. Old code still works, because a rollback redeploys it.
4. **Contract** — remove the old shape only after every running version ignores it. That is a later step and a later release.

A destructive change in the same release as the code that starts depending on the new shape is a failed step. Split it.

## Rollback

Prefer a rollback that redeploys the previous application image without a down migration that loses data written by the new code. When that is impossible, say so in the step record before the step is merged, and name the forward fix. The step also names the production signal that triggers that rollback. Running the migration, the backfill, or the reversal needs a human approval. The agent does not do it, and does not do it in production.

## Migrations versus refactors

A migration unit touches the schema only when the runtime or framework hop forces it (driver change, a framework's required schema). A refactor unit touches the schema only when the structural step cannot ship without the new shape. Anything else waits for its own step. Charset conversions are data steps: record the current encoding, and do not convert in passing.
