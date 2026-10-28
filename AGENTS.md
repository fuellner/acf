# AGENTS.md

Short index for AI agents. Read this first, follow the links for details.

## Project

Collection of agent-agnostic coding skills for OpenCode / Claude-compatible harnesses. Each skill is a Markdown instruction set that drives a coding workflow and writes structured documents into a target repository.

## Stack

- Markdown only — no runtime, build, or test toolchain
- Skill format: `SKILL.md` with YAML frontmatter (`name`, `description`)
- Installed by symlinking `skills/f-*` into an agent skill directory

## Commands

- Install: `mkdir -p ~/.config/opencode/skills && ln -s ~/dev/acf/skills/f-* ~/.config/opencode/skills/`
- Verify installation: `ls -l ~/.config/opencode/skills`
- Test / Lint / Typecheck: none — there is no toolchain. Validate a change by reading the affected `SKILL.md` and running the skill against a test repository.

## Conventions

Follow the conventions in `docs/conventions/`. The rules below always apply:

- Prefer the smallest change that fully satisfies the requirement. Do not add extra features, abstractions, or improvements.
- Never perform drive-by changes or refactorings. Only modify what is necessary for the current task.
- Never introduce new concepts, patterns, or abstractions unless they are strictly necessary to fulfill the requirement.
- Match the existing style, naming, and structure of the surrounding skill. Do not introduce a new style for a single change.
- Keep skill instructions English. Exception: `f-legal` instructions, its templates, and generated `docs/legal/` are German. Human-facing documents in the target repository (README, architecture, decisions) are German. `f-feature-summary` instructions stay English; its templates and generated `docs/features/` are German. `f-refactor` instructions, its templates, and generated `docs/refactor/` are English.
- Do not add comments or sections that merely restate what is already obvious. Only document reasons and constraints that are non-obvious.

## Boundaries

- Ask first before renaming a skill directory or changing its frontmatter `name` — installed symlinks and invocations depend on both.
- Never modify the remote repository (no push, no force-push, no direct remote changes of any kind).
- Never commit `.env` files or any secrets.
- `docs/legal/` is owned exclusively by `f-legal`. `f-docs` must never create, fill, or update it.
- `docs/refactor/` in a target repository belongs to `f-refactor`, a separate workflow from `f-workflow`. Other skills write there only the task links and status updates those skills already define.
- `skills/<name>/templates/` is the source of truth. Running a skill must not modify the templates in this repository; generated documents belong in the target repository.
- Do not create a template named `AGENTS.md` — agent harnesses auto-load that filename as active instructions.

## Deeper docs

- [docs/architecture.md](docs/architecture.md) — System structure and boundaries
- [docs/decisions/](docs/decisions/) — Decision records
- [docs/conventions/](docs/conventions/) — Coding standards
