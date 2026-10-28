# Toolchain

Deterministic checks are the gate. The agent chooses a seam, reads the output, and records it. It does not override a failing check, delete a sniff, edit an assertion, or refresh a golden file to make a step look green. A red result means the step is not `ready-for-review`.

Licenses and the commercial-use note are in `tool-licenses.md`. Framework caveats are in `php.md`. Golden-master rules are in `characterization-tests.md`.

## Detect, then ask

Read `composer.json` (`require-dev` and `scripts`), the existing config (`rector.php`, `phpstan.neon` or `phpstan.neon.dist`, `psalm.xml`, `deptrac.yaml`, `phpcs.xml` or `phpcs.xml.dist`, `phpunit.xml` or `phpunit.xml.dist`), and the CI config. Use the binary and the config the repository already runs. If both PHPStan and Psalm are present, use the one CI runs.

Do not `composer require` a missing tool, and do not add a CI job for a tool the repository does not have, until you ask and the user accepts the dependency. The optional installer is `scripts/install-tools.sh`. Ask before running it, including a dry-run. Record a missing tool as a gap. Do not pretend the check ran.

Commands below are examples. Substitute the path and the version the repository actually uses. The PHP minor comes from the php.net page fetched this session, not from memory.

## Tools

| Tool | Phase | What it decides | Example | How to read it |
|------|-------|-----------------|---------|----------------|
| Rector | `execute` (a migration hop or a codemod) | Mechanical diff for one rule set | `vendor/bin/rector process src --dry-run` | Review the diff. Dry-run first. One set per PR. A clean run is not proof that behavior held. An unexpected edit stops the step. Phalcon C-extension classes are invisible without stubs. |
| PHPCompatibility on PHP_CodeSniffer | `inventory`, `plan`, `execute` for a migration | Source that will not run on the target PHP | `vendor/bin/phpcs --standard=vendor/phpcompatibility/php-compatibility/PHPCompatibility --runtime-set testVersion <target> src` | Errors are forced-fix candidates. Confirm each one against the migration guide fetched for that hop. Do not silence a sniff to go green. If the project already registers the standard, `--standard=PHPCompatibility` is enough. The installer does not add a Composer plugin to register it. |
| PHPStan or Psalm | `execute` | New static errors against the committed baseline | `vendor/bin/phpstan analyse` or `vendor/bin/psalm` | New errors fail the step. Do not clear baseline entries as a side effect. Set the language level to the target on a migration and to the current runtime on a refactor. |
| Deptrac | `plan` and `execute` for a refactor boundary | Whether a new module boundary holds | `vendor/bin/deptrac analyse` | A new violation fails the step. Add a rule only for the boundary this step introduces. Prefer the boundary tool the repo already runs. The installer adds `deptrac/deptrac` and does not add the abandoned `qossmic/deptrac` package. |
| PHPUnit, including golden masters | `safety-net` (the plan, via `f-testing`) and `execute` | Observed behavior at the seam | `vendor/bin/phpunit --filter <seam>` | Tests must pass on the unchanged code before the edit. A migration runs the same suite on the old runtime and the target and diffs normalized output. A failure or a golden diff means behavior changed. Do not edit the expected value. Timestamps, ids, session tokens, and random values are normalized first. |
| Composer `why-not` | `inventory`, `plan` | Which packages block the target PHP | `composer why-not php <target>` | A blocking package is a migration fact, not a reason to ignore the platform. Replacing it needs approval. `config.platform.php` can lie; check the real runtime too. |
| Composer `audit` | `inventory`, `close-out` | Known dependency advisories | `composer audit` | Findings are recorded. An abandoned package is removed or explicitly accepted. Do not `composer update` without approval. Installed packages keep their own licenses. |
| Git history | `inventory`, `prioritize` | Where churn is, inside a security tier | `git log --since=<window> --pretty=format: --name-only` | Record the command and the window. High churn on the planned path is a tie-break. Low churn is not proof that code is unused. Dead code still needs production evidence. |
| CI version matrix | `plan`, `execute`, `close-out` | The suite on the production runtime and the hop target | The repository's existing CI config | Add the hop target next to the current production runtime. A red job fails the step. Drop the old runtime only when production no longer runs it. Do not delete a job to go green. |

`phalcon/ide-stubs` is a detection aid for Rector and PHPStan when the app uses Phalcon. It is not a gate. Ask before adding it.

## What the agent does

The agent selects the seam, runs the tool that is already installed, and writes the command and the result into the step record or the inventory. Interpretation stops at what the tool printed.

The agent does not treat a green Rector run as a behavior proof, a PHPStan baseline as permission to edit unrelated errors, or a missing tool as a passed check. Characterization oracles and golden masters are the behavior gate. Static tools are the mechanical gate. Both have to pass. A Composer resolution failure is not fixed by `--ignore-platform-reqs`.

## Optional installer

`scripts/install-tools.sh` adds tools to one existing project. It does not create `composer.json`, does not search parent directories, and does not install anything globally.

```bash
scripts/install-tools.sh --help
scripts/install-tools.sh --project-dir /path/to/app --phpstan --phpunit
scripts/install-tools.sh --project-dir /path/to/app --all
scripts/install-tools.sh --project-dir /path/to/app --install --phpcs --phpcompatibility
```

Ask the user before any of these. The first three are dry-runs. Only `--install` runs Composer.

What it will do:

- `composer require --dev` for the selected packages, with `--no-interaction`, `--no-plugins`, and `--no-scripts`. Project Composer scripts do not run.
- Skip a package that is already in `require-dev`, and leave that constraint unchanged.
- Skip a package that is already in `require`. It does not move or upgrade non-dev dependencies.
- Choose the constraint from the table below using the composer platform PHP: `config.platform.php` when set, otherwise the `php` on `PATH`.
- Print each selected package's SPDX id and the path to `tool-licenses.md`.
- Require PHP CLI and Composer 2.4 or newer (`composer audit` shipped in 2.4). It does not download or upgrade Composer.

`--all` selects Rector, PHPStan, Deptrac, PHP_CodeSniffer, PHPCompatibility, and PHPUnit. Psalm is the alternative to PHPStan and is not in `--all`. `--phalcon-stubs` needs the extension major (`3`, `4`, or `5`) because the PHP version does not imply it. PHPCompatibility also selects PHP_CodeSniffer 3 when that package is not already a dev dependency. PHPCompatibility 9 does not run on PHP_CodeSniffer 4, and an existing `^4` pin is not downgraded.

When the platform PHP is too old for a tool, the tool is skipped. Run this same script in a separate Composer project on a newer PHP, and point the tools at the legacy tree. Tests that claim behavior on the old runtime still run on that runtime. The script does not install PHPUnit 4, 5, or 6, and it does not install PHP_CodeSniffer 2.

## Supply chain

Installation from this skill is Composer against `https://repo.packagist.org` only. The script refuses anything else before it changes the project.

Official package names, checked on 2026-10-27 against each project's README and the Packagist repository URL:

| Tool | Packagist name | Not accepted |
|------|----------------|--------------|
| Rector | `rector/rector` | Any other Rector package or fork |
| PHPStan | `phpstan/phpstan` | |
| Psalm | `vimeo/psalm` | |
| Deptrac | `deptrac/deptrac` | `qossmic/deptrac` (Packagist marks it abandoned) |
| PHP_CodeSniffer | `squizlabs/php_codesniffer` | `phpcsstandards/php_codesniffer` (Packagist marks it abandoned and points back at `squizlabs/php_codesniffer`). The GitHub repository is `PHPCSStandards/PHP_CodeSniffer`; the Composer name did not change. |
| PHPCompatibility | `phpcompatibility/php-compatibility` | |
| PHPUnit | `phpunit/phpunit` | |
| Phalcon stubs | `phalcon/ide-stubs` | |

The script hardcodes that list. A constraint must be `^MAJOR.MINOR` for one of those names. `*`, `dev-`, a git URL, a path, and a fork are refused.

Composer must already be installed. This script does not run `curl | sh`, `wget`, or a PHAR download, and it does not add a repository.

- `secure-http` must be `true`. `disable-tls` must be `false`. `COMPOSER_DISABLE_TLS` must be unset.
- The effective repository list must be only `https://repo.packagist.org`. A mirror, a path repository, a VCS repository, or `packagist.org: false` is refused. The script does not add one.
- `composer require --dev` updates `composer.lock` for the added packages and their dependencies. It does not run a bare `composer update`, so other locked packages stay at the versions already in the lock.
- After a successful require, the script runs `composer audit --locked`. Advisories fail the run (exit 5). The script does not pass `--no-dev` and does not hide abandoned packages. Findings that were already in the lock are still reported.

Exit `6` means the package, the TLS settings, or the repository list was outside this rule. `composer.json` is left unchanged in that case.

### Newer PHP, still the same installer

A PHP that is too old to run a tool needs a newer PHP binary. The tools are still installed by this script, from packagist.org, in a Composer project that is not pinned to the legacy version.

The only container image these docs name is the Docker Official Image `php`, built from [docker-library/php](https://github.com/docker-library/php) and published as `php` (not a third-party name). Do not use a fork or a community PHP image. Before using a tag, inspect its provenance as documented by Docker: `docker buildx imagetools inspect php:<tag> --format '{{json .Provenance}}'` ([Build attestations](https://docs.docker.com/build/metadata/attestations/)). Confirm the repository is the official `php` image. Then run this script inside that environment.

### PHARs are not an install path

Upstream READMEs also show PHAR downloads (`https://phars.phpcodesniffer.com`, `https://phar.phpunit.de`, and similar). This skill does not run those commands and does not treat a PHAR as a substitute for the allowlist. If an operator installs a PHAR outside this skill, the only acceptable file is one from that project's own release, checked the way that project documents. For PHP_CodeSniffer that is the PHAR from `phars.phpcodesniffer.com` or the `PHPCSStandards/PHP_CodeSniffer` GitHub release, signed with the release key fingerprint `D91D86963AF3A29B6520462297B02DD8E5071466`, and for 3.10.3 or newer `gh attestation verify phpcs.phar -o PHPCSStandards`. Do not take the file from a mirror, a fork, or an unsigned copy.

| Platform PHP | Package |
|--------------|---------|
| `>= 7.4` | `rector/rector:^2.0` |
| `>= 7.2` and `< 7.4` | `rector/rector:^1.2` |
| `>= 7.4` | `phpstan/phpstan:^2.0` |
| `>= 7.2` and `< 7.4` | `phpstan/phpstan:^1.12` |
| `>= 8.4.3` and `< 8.6` | `vimeo/psalm:^6.0` |
| `>= 7.4` and `< 8.4` | `vimeo/psalm:^5.26` |
| `>= 7.1` and `< 7.4` | `vimeo/psalm:^4.30` |
| `8.4.0`–`8.4.2` | Psalm skipped. Psalm 6 requires `>= 8.4.3` on that line, and Psalm 5 does not support 8.4. |
| `>= 8.2` and `< 9` | `deptrac/deptrac:^4.0` |
| `>= 8.1` and `< 8.2` | `deptrac/deptrac:^3.0` |
| `>= 5.4` | `squizlabs/php_codesniffer:^3.13` |
| `>= 5.4` | `phpcompatibility/php-compatibility:^9.3` |
| `>= 8.4.1` | `phpunit/phpunit:^13.0` |
| `>= 8.3` and `< 8.4.1` | `phpunit/phpunit:^12.0` |
| `>= 8.2` and `< 8.3` | `phpunit/phpunit:^11.0` |
| `>= 8.1` and `< 8.2` | `phpunit/phpunit:^10.5` |
| `>= 7.3` and `< 8.1` | `phpunit/phpunit:^9.6` |
| `>= 7.2` and `< 7.3` | `phpunit/phpunit:^8.5` |
| `>= 7.1` and `< 7.2` | `phpunit/phpunit:^7.5` |
| `>= 8.1`, `--phalcon-stubs 5` | `phalcon/ide-stubs:^5.0` |
| `>= 7.2`, `--phalcon-stubs 4` | `phalcon/ide-stubs:^4.0` |
| `--phalcon-stubs 3` | `phalcon/ide-stubs:^3.4` (the 3.4.3 release publishes no PHP requirement; confirm the major) |

Anything older is skipped. PHP 5.3 gets no packages from this script.

Exit codes: `0` plan or install finished, including "already present" and a clean audit; `1` bad usage; `2` missing PHP, Composer, or `composer.json`, or Composer older than 2.4; `3` `composer require` failed; `4` nothing was added and every selected tool was refused; `5` `composer audit` reported advisories; `6` the package, TLS setting, or repository is outside the packagist.org allowlist. Keep this table in step with `choose_constraint` in the script.
