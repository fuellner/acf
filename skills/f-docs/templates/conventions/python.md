# Python Conventions

These rules apply to all Python code in this repository.

## Changes
- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings; modify only what the current task requires.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and patterns in the surrounding code. Do not introduce a new style for a single change.
- Prefer early returns over deeply nested conditionals when it reduces complexity.
- Do not add comments that merely describe what the code does. Only add comments when the reason or constraint is non-obvious.

## Style & Structure
- Follow PEP 8 unless the surrounding code explicitly deviates.

## Type Hints
- Use type hints on public functions and methods when the surrounding code already uses them.
- Do not introduce type hints in a file or module that currently has none, unless the task explicitly requires it.

## Imports
- Never use `from module import *`.
- Keep imports at the top of the file. Match the existing import style.

## Dependencies
- Add a dependency only when the task explicitly requests it.
- Use the package manager already present in the repository (`uv.lock`, `poetry.lock`, `Pipfile`, or `requirements.txt`). Do not introduce another one.

## Error Handling
- Do not introduce bare `except:` or empty except blocks.
- Match the existing error handling style of the surrounding code.
