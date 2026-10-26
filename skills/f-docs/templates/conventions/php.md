# PHP Conventions

These rules apply to all PHP code in this repository.

## Style & Structure
- Follow PSR-12 unless the surrounding code explicitly deviates.

## Language Features
- Never use `extract()`.
- Never use `eval()`.
- Never use dynamic includes or requires with user-controlled paths.
- Prefer typed properties and return types when the surrounding code already uses them.

## Dependencies
- Add dependencies only via Composer. Never manually edit `composer.json` or `vendor/`.

## Error Handling
- Do not introduce empty catch blocks.
- Match the existing error handling style of the surrounding code.

## Database & Queries
- Prefer parameterized queries or the existing query builder / ORM style. Never concatenate user input into SQL strings.
