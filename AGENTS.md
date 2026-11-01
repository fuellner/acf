# AGENTS.md

Short index for humans and agents. Hard rules live here. Load a linked file only when the task needs it.

## Conventions

- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings. Only modify what is necessary for the current task.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and structure of the surrounding skill. Do not introduce a new style for a single change.
- Do not add comments or sections that merely restate what is already obvious. Only document reasons and constraints that are non-obvious.
- Never add new dependencies unless explicitly requested.
- Prefer early returns over deeply nested conditionals when it reduces complexity.

## Boundaries

- Ask first before adding any new dependency.
- Ask first before changing authentication, permissions, or access control.
- Never modify the remote repository (no push, no force-push, no direct remote changes of any kind).
- Never modify any database (no schema changes, no migrations, no data changes, no queries that alter state).
- Never call external APIs.
- Never log, store, transmit, or include personal data (or any data that could identify a person) in context, logs, or output.
- Never commit `.env` files or any secrets.
- Never manually edit generated files.

## Subagents

Spawn a subagent on your own when the work splits into independent parts, needs a lot of reading (a broad search or logs), or benefits from a specialist focus such as security or test gaps.

Leave small, sequential, or tightly coupled work on the main thread. Never have several agents edit the same files in parallel.

Each subagent returns a concise summary with file and line references, not raw logs. The parent merges those results and never delegates the same work twice.

## Model and reasoning

Before every spawn, classify the delegated task as one tier. Pass both the model and the reasoning level on that spawn. Pass them again even when the parent already uses the same settings.

| Tier | Use for | Model | Reasoning | Model id |
|------|---------|-------|-----------|----------|
| mechanical | search, extraction, formatting, a single-symbol lookup | cheapest/fast | low | — |
| bounded | one clear change, a straightforward review, a limited summary | inherit | medium | — |
| complex | architecture, multi-module debugging, security, conflicting evidence | strongest | high | — |

Maintain the table by hand or let an agent update it. The Model and Reasoning columns are the defaults. A concrete model id is optional: write it in the last column for this project. When a listed id is unavailable, use inherit.

Pass model and reasoning level via the current tool's own fields; this file requires no model id.

## Memory

Keep three files in the project root. Read them before non-trivial work. Add to them during the work. Do not scan the repository to fill them up front.

- `MEMORY.md` — stable, confirmed knowledge. One dated bullet per fact.
- `LEARNINGS.md` — new, unconfirmed observations. One dated heading, then a few bullets.
- `ERRORS.md` — recurring errors. Each entry has symptom, cause, fix, and last seen.

Promote a confirmed or repeated learning from `LEARNINGS.md` to `MEMORY.md`, or to `ERRORS.md` when it is a failure mode, and remove it from `LEARNINGS.md`. Update an existing entry instead of adding a near-duplicate. Never store secrets, one-off details, or temporary state.

The format is in `MEMORY.md`, `LEARNINGS.md`, and `ERRORS.md`.

## Boundaries

- Ask first before adding a dependency or changing authentication, permissions, or access control.
- Never commit `.env` files or any secrets. Never log, store, transmit, or include personal data.
- Never manually edit generated files.
- Never modify the remote repository, never modify any database, and never call external services at runtime unless the task explicitly requires it.

## Documentation

Keep rules and files to the minimum. Update an existing file instead of creating a new one. Add a file only when the information is stable, reusable, and does not belong in the memory files. Keep this index short.

## Deeper docs

read if present and context requires it

- [docs/architecture.md](docs/architecture.md) — System structure and boundaries
- [docs/decisions/](docs/decisions/) — Decision records
- [docs/conventions/](docs/conventions/) — Coding standards
