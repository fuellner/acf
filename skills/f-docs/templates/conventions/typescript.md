# TypeScript Conventions

These rules apply to all TypeScript code in this repository. Framework: [detected, e.g. Angular, React, Node].

## Types
- Avoid `any`. Only use it if the surrounding code already uses it in the same way or the task explicitly requires it.
- Use `import type` for type-only imports when the surrounding code does so.
- Do not introduce new type patterns or utility types unless the surrounding code already uses them or the task explicitly requires it.

## Exports
- Match the existing export style (named exports vs. default exports) of the surrounding code. Do not switch styles in a single change.
