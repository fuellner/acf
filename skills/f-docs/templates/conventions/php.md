# PHP Conventions

These rules apply to all PHP code in this repository.

## Changes
- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings; modify only what the current task requires.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and patterns in the surrounding code. Do not introduce a new style for a single change.
- Prefer early returns over deeply nested conditionals when it reduces complexity.
- Do not add comments that merely describe what the code does. Only add comments when the reason or constraint is non-obvious.

## Style & Structure
- Follow PSR-12 unless the surrounding code explicitly deviates.

## Language Features
- Never use `extract()`.
- Never use `eval()`.
- Never use dynamic includes or requires with user-controlled paths.
- Prefer typed properties and return types when the surrounding code already uses them.

## Dependencies
- Add a dependency only when the task explicitly requests it, and only via Composer. Never manually edit `composer.json` or `vendor/`.

## Error Handling
- Do not introduce empty catch blocks.
- Match the existing error handling style of the surrounding code.

## Database & Queries
- Prefer parameterized queries or the existing query builder / ORM style. Never concatenate user input into SQL strings.
