# SQL Conventions

These rules apply to all SQL in this repository (raw SQL and query builder usage). Primary database: [detected: name + version].

## Queries
- Never use `SELECT *` in new or modified queries. List the required columns explicitly.
- Never concatenate user input or variables into SQL strings. Use parameterized queries, prepared statements, or the existing query builder style.
- Match the existing query style (naming, formatting, joins, aliases) in the surrounding code.
- When using a query builder (the framework in use), prefer the builder methods over raw SQL unless the existing code or the requirement makes raw SQL clearer.

## Schema & Changes
- Never modify database schema, create migrations, or alter existing tables unless the task explicitly requires it.
- Never execute queries that modify data (INSERT, UPDATE, DELETE, TRUNCATE) unless the task explicitly requires it.

## Naming & Structure
- Follow the naming conventions of the existing tables and columns. Do not introduce a new naming style.
- Prefer explicit JOINs over implicit joins in the WHERE clause when writing new queries.
- Use consistent aliasing. Match the existing alias style in the surrounding code.
