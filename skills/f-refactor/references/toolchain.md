# Toolchain

Deterministic checks are the gate. The agent chooses a seam, reads the output, and records it. It does not override a failing check, delete a sniff, edit an assertion, or refresh a golden file to make a step look green. A red result means the step is not `ready-for-review`.

Licenses and the commercial-use note are in `tool-licenses.md`. Framework caveats are in `php.md`. Golden-master rules are in `characterization-tests.md`.

## Detect, then ask

Read `composer.json` (`require-dev` and `scripts`), the existing config (`rector.php`, `phpstan.neon` or `phpstan.neon.dist`, `psalm.xml`, `deptrac.yaml`, `phpcs.xml` or `phpcs.xml.dist`, `phpunit.xml` or `phpunit.xml.dist`), and the CI config. Use the binary and the config the repository already runs. If both PHPStan and Psalm are present, use the one CI runs.

Do not `composer require` a missing tool, and do not add a CI job for a tool the repository does not have, until you ask and the user accepts the dependency. Record a missing tool as a gap. Do not pretend the check ran.

Commands below are examples. Substitute the path and the version the repository actually uses. The PHP minor comes from the php.net page fetched this session, not from memory.

## Tools

| Tool | Phase | What it decides | Example | How to read it |
|------|-------|-----------------|---------|----------------|
| Rector | `execute` (a migration hop or a codemod) | Mechanical diff for one rule set | `vendor/bin/rector process src --dry-run` | Review the diff. Dry-run first. One set per PR. A clean run is not proof that behavior held. An unexpected edit stops the step. Phalcon C-extension classes are invisible without stubs. |
| PHPCompatibility on PHP_CodeSniffer | `inventory`, `plan`, `execute` for a migration | Source that will not run on the target PHP | `vendor/bin/phpcs --standard=PHPCompatibility --runtime-set testVersion <target> src` | Errors are forced-fix candidates. Confirm each one against the migration guide fetched for that hop. Do not silence a sniff to go green. |
| PHPStan or Psalm | `execute` | New static errors against the committed baseline | `vendor/bin/phpstan analyse` or `vendor/bin/psalm` | New errors fail the step. Do not clear baseline entries as a side effect. Set the language level to the target on a migration and to the current runtime on a refactor. |
| Deptrac | `plan` and `execute` for a refactor boundary | Whether a new module boundary holds | `vendor/bin/deptrac analyse` | A new violation fails the step. Add a rule only for the boundary this step introduces. The upstream repository is archived; prefer the boundary tool the repo already runs. |
| PHPUnit, including golden masters | `safety-net` (the plan, via `f-testing`) and `execute` | Observed behavior at the seam | `vendor/bin/phpunit --filter <seam>` | Tests must pass on the unchanged code before the edit. A migration runs the same suite on the old runtime and the target and diffs normalized output. A failure or a golden diff means behavior changed. Do not edit the expected value. Timestamps, ids, session tokens, and random values are normalized first. |
| Composer `why-not` | `inventory`, `plan` | Which packages block the target PHP | `composer why-not php <target>` | A blocking package is a migration fact, not a reason to ignore the platform. Replacing it needs approval. `config.platform.php` can lie; check the real runtime too. |
| Composer `audit` | `inventory`, `close-out` | Known dependency advisories | `composer audit` | Findings are recorded. An abandoned package is removed or explicitly accepted. Do not `composer update` without approval. Installed packages keep their own licenses. |
| Git history | `inventory`, `prioritize` | Where churn is, inside a security tier | `git log --since=<window> --pretty=format: --name-only` | Record the command and the window. High churn on the planned path is a tie-break. Low churn is not proof that code is unused. Dead code still needs production evidence. |
| CI version matrix | `plan`, `execute`, `close-out` | The suite on the production runtime and the hop target | The repository's existing CI config | Add the hop target next to the current production runtime. A red job fails the step. Drop the old runtime only when production no longer runs it. Do not delete a job to go green. |

`phalcon/ide-stubs` is a detection aid for Rector and PHPStan when the app uses Phalcon. It is not a gate. Ask before adding it.

## What the agent does

The agent selects the seam, runs the tool that is already installed, and writes the command and the result into the step record or the inventory. Interpretation stops at what the tool printed.

The agent does not treat a green Rector run as a behavior proof, a PHPStan baseline as permission to edit unrelated errors, or a missing tool as a passed check. Characterization oracles and golden masters are the behavior gate. Static tools are the mechanical gate. Both have to pass.
