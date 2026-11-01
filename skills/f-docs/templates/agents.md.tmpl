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
- Never modify any database (no schema changes, no migrations, no data changes, no queries that alter state).
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

## Memory

Three files in the project root. Create a file when it is missing and you have its first entry; do not scan the repository to fill them up front. Read them before a change that spans more than one file, in an unfamiliar area, and when debugging.

| File | Content | Limit | Format |
|------|---------|-------|--------|
| `MEMORY.md` | stable, confirmed facts | ~50 | `# Memory` heading, one bullet per fact: `- YYYY-MM-DD — fact` |
| `LEARNINGS.md` | new, unconfirmed observations | ~10 open | `# Learnings` heading, per entry `## YYYY-MM-DD — title`, then bullets; the date is the first observation |
| `ERRORS.md` | recurring failures | ~20 | `# Errors` heading, per entry `## YYYY-MM-DD — short name`, then bullets `Symptom:`, `Cause:`, `Fix:`, `Last seen: YYYY-MM-DD` |

Code and docs win over memory. On a conflict, verify and correct the entry instead of following it. If memory files differ between machines, re-verify the contested fact before keeping either version.

Add a fact to `MEMORY.md` only after verifying it (command, test, or authoritative file); the date is the verification date. Promote a confirmed or repeated learning from `LEARNINGS.md` to `MEMORY.md`, or to `ERRORS.md` when it is a failure mode, and remove it from `LEARNINGS.md`. Update an existing entry instead of adding a near-duplicate. When a file reaches its limit, drop outdated entries or merge them. Remove template placeholder lines with the first real entry. Never store secrets, one-off details, or temporary state.

Keep `MEMORY.md` and `ERRORS.md` in version control; add `LEARNINGS.md` to the project's `.gitignore`.

## Documentation

Keep rules and files to the minimum. Update an existing file instead of creating a new one. Add a file only when the information is stable, reusable, and does not belong in the memory files. Keep this index short.

## Deeper docs

Read when present:

- `README.md` — project, stack, and commands
- `docs/architecture.md` — system structure and boundaries
- `docs/decisions/` — decision records
- `docs/conventions/` — coding standards
