# Python Conventions

These rules apply to all Python code in this repository.

## Style & Structure
- Follow PEP 8 unless the surrounding code explicitly deviates.

## Type Hints
- Use type hints on public functions and methods when the surrounding code already uses them.
- Do not introduce type hints in a file or module that currently has none, unless the task explicitly requires it.

## Imports
- Never use `from module import *`.
- Keep imports at the top of the file. Match the existing import style.

## Dependencies
- Use the package manager already present in the repository (`uv.lock`, `poetry.lock`, `Pipfile`, or `requirements.txt`). Do not introduce another one.

## Error Handling
- Do not introduce bare `except:` or empty except blocks.
- Match the existing error handling style of the surrounding code.
