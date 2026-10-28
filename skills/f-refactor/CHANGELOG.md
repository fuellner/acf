# Changelog

## 2026-10-28
- Tools are no longer installed with `composer require --dev` in the application. `scripts/toolchain/` builds a container image (Docker or Podman) or installs the same lock into a directory outside the app. One Composer source: packagist.org, or one internal HTTPS repository with packagist.org disabled. The tool lock is required. `--write-lock` is the explicit step that creates it. `run.sh` uses `--network none`, a read-only application mount, and writes reports to a separate directory. Rector and phpcbf stay on diff output.
- `scripts/install-tools.sh` was removed. It refused a missing application `composer.lock` before `composer require`. That lock check now applies to the tool project.
- Feature flag is a strategy: default off, a named owner, rollout by turning the flag on, and removal as a later step of the same unit.
- A wide PHP gap in CI is 5.6, then 7.4 (read the 7.0–7.3 migration guides), then 8.0, 8.1, 8.2, and on to the fetched target.
- PHPCompatibility's SPDX id is `LGPL-3.0-or-later`. The toolchain example sets `testVersion` to a range from the current runtime to the target. An existing PHP_CodeSniffer `^4` or `>=4` pin is not downgraded. Commit `composer.lock` and review the lock diff before committing.

## 2026-10-27
- `scripts/install-tools.sh` installs only an allowlist of official Packagist packages over HTTPS. It refuses mirrors, custom repositories, disabled TLS, abandoned package names, PHARs, and `curl | sh`. `composer audit --locked` runs after install.
- `scripts/install-tools.sh` optionally adds selected tools as Composer dev dependencies. Dry-run unless `--install`. It skips packages already in `composer.json`, refuses a platform PHP that cannot run the tool, and does not touch `require` or production. The agent asks before running it.
- `references/workflow.md` is the human-readable map of phases, artifacts, status, and handoffs. `references/toolchain.md` is the tool gate: detect what `composer.json` already has, ask before installing, and do not override a failing check.
- `references/tool-licenses.md` lists every external tool this skill names, with the SPDX id and license link re-checked against the GitHub API.
- `f-refactor` is a separate workflow with its own phase menu, parallel to `f-workflow`. It reuses `f-tasks`, `f-testing`, `f-code-review`, `f-debug`, and `f-docs`.
- Index columns gain Phase and Effort. The index is the cross-unit progress view.
- Guardrails: production access is off-limits; database migrations, staging, dependency upgrades, deletions, and deploys need human approval.
- Inventory records non-web entry points and environment parity. Steps record a revert path and the production signal that triggers rollback. Close-out records performance before and after.
- Golden masters normalize nondeterministic fields, ban production data, and may not be refreshed without a written reason.
- Initial creation of f-refactor.
- One skill, two required unit types: `migration` (primary) and `refactor`. Behavior stays the same; bugs are recorded, not fixed; each step is releasable on its own.
- Artifacts under `docs/refactor/REF-<id>-<slug>/` so a later session can resume without chat history.
- References for PHP version upgrades, large legacy codebases, structural strategies, PHP tools, database expand/contract, and characterization tests.
