# SQL Conventions

These rules apply to all SQL in this repository (raw SQL and query builder usage). Primary database: [detected: name + version].

## Changes
- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings; modify only what the current task requires.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and patterns in the surrounding code. Do not introduce a new style for a single change.
- Do not add comments that merely describe what the code does. Only add comments when the reason or constraint is non-obvious.

## Queries
- Never use `SELECT *` in new or modified queries. List the required columns explicitly.
- Never concatenate user input or variables into SQL strings. Use parameterized queries, prepared statements, or the existing query builder style.
- Match the existing query style (naming, formatting, joins, aliases) in the surrounding code.
- When using a query builder (the framework in use), prefer the builder methods over raw SQL unless the existing code or the requirement makes raw SQL clearer.

## Schema & Changes
- Modify database schema, create migrations, or alter existing tables only when the user explicitly requests or approves it, and only against an isolated test database. If unclear, ask.
- Execute queries that modify data (INSERT, UPDATE, DELETE, TRUNCATE) only when the user explicitly requests or approves it. If unclear, ask.

## Naming & Structure
- Follow the naming conventions of the existing tables and columns. Do not introduce a new naming style.
- Prefer explicit JOINs over implicit joins in the WHERE clause when writing new queries.
- Use consistent aliasing. Match the existing alias style in the surrounding code.
