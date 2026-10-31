# TypeScript Conventions

These rules apply to all TypeScript code in this repository. Framework: [detected, e.g. Angular, React, Node].

## Changes
- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings; modify only what the current task requires.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and patterns in the surrounding code. Do not introduce a new style for a single change.
- Prefer early returns over deeply nested conditionals when it reduces complexity.
- Do not add comments that merely describe what the code does. Only add comments when the reason or constraint is non-obvious.

## Dependencies
- Add a dependency only when the task explicitly requests it. Use the package manager already present in the repository.

## Types
- Avoid `any`. Only use it if the surrounding code already uses it in the same way or the task explicitly requires it.
- Use `import type` for type-only imports when the surrounding code does so.
- Do not introduce new type patterns or utility types unless the surrounding code already uses them or the task explicitly requires it.

## Exports
- Match the existing export style (named exports vs. default exports) of the surrounding code. Do not switch styles in a single change.
