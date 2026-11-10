# AGENTS.md

Short index for humans and agents. Hard rules live here. Load a linked file only when the task needs it.

## Conventions

- Make the smallest change that fully satisfies the requirement: no extra features, abstractions, refactorings, or drive-by changes.
- Introduce a new concept or pattern only when the task cannot be met without it; otherwise match the existing style, naming, and structure.
- Do not add comments or sections that merely restate what is already obvious. Only document reasons and constraints that are non-obvious.

## Boundaries

- Ask first before adding a new dependency.
- Ask first before changing authentication, permissions, or access control.
- Never modify the remote repository (no push, no force-push, no direct remote changes of any kind).
- Never commit, push, stage, or change the git identity without explicit user approval.
- Never touch a production or shared database. Ask before any schema change, migration, backfill, or data change; run such work only against an isolated test database.
- No production access: no production shell, database, logs, or deploy.
- Never call external APIs or services unless the task explicitly requires it.
- Never log, store, transmit, or include personal data (or any data that could identify a person) in context, logs, or output.
- Never commit `.env` files or any secrets.
- Never manually edit generated files.

## Subagents

Spawn a subagent on your own when the work splits into independent parts, needs a lot of reading (a broad search or logs), or benefits from a specialist focus such as security or test gaps.

Leave small, sequential, or tightly coupled work on the main thread. Never have several agents edit the same files in parallel.

Each subagent returns a concise summary with file and line references, not raw logs. The parent merges those results and never delegates the same work twice.

Before every spawn, classify the task as one tier and pass both its model and reasoning level on that spawn, even when the parent uses the same settings.

| Tier | Use for | Model | Reasoning | Model id |
|------|---------|-------|-----------|----------|
| mechanical | search, extraction, formatting, a single-symbol lookup | cheapest capable | low | — |
| bounded | one clear change, a straightforward review, a limited summary | inherited | medium | — |
| complex | architecture, multi-module debugging, security, conflicting evidence | strongest available | high | — |

Resolve the model from the harness model list and pass it through the tool's own fields. A project may pin concrete ids in the last column; an empty cell means resolve at runtime. When two tiers fit, start with the lower one and escalate only after it fails. Update the pinned ids when the harness model list changes.

## Documentation

Keep rules and files to the minimum. Update an existing file instead of creating a new one. Add a file only when the information is stable and reusable. Keep this index short.

## Deeper docs

Read when present:

- `README.md` — project, stack, and commands
- `docs/architecture.md` — system structure and boundaries
- `docs/decisions/` — decision records
- `docs/conventions/` — coding standards
