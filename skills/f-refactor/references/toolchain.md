# Toolchain

Deterministic checks are the gate. The agent chooses a seam, reads the output, and records it. It does not override a failing check, delete a sniff, edit an assertion, or refresh a golden file to make a step look green. A red result means the step is not `ready-for-review`.

Licenses and the base-image note are in `tool-licenses.md`. Framework caveats are in `php.md`. Golden-master rules are in `characterization-tests.md`. The decision to keep tools out of the application is [0006](../../../docs/decisions/0006-werkzeugkette-container-eine-composer-quelle.md).

## Why the tools are not in the application

`composer require --dev` inside the application is not this skill's install path.

Two constraints make that install wrong. The application may use a Composer repository that does not offer `https://repo.packagist.org`. And the application may run PHP 5.3 or another old runtime, while Rector 2, PHPStan 2, and Psalm 6 need PHP 8.4. Putting those packages in the application's `require-dev` would either fail the resolve or change production dependencies.

The tools live in their own Composer project:

- Primary: a container image built from `scripts/toolchain/`. The application tree is mounted read-only at run time.
- Fallback: a directory outside the application repo, with the same `composer.json` and `composer.lock`.

The application's `composer.json`, `composer.lock`, and `vendor/` are not modified. Ask before running any of these scripts, including a dry-run.

## Layout

```text
scripts/toolchain/
  Dockerfile          # tool image, PHP base pinned by digest
  composer.json       # direct tool requirements only
  composer.lock       # committed lock for that project
  build.sh            # dry-run unless --build or --write-lock
  run.sh              # dry-run unless --run
  install-host.sh     # directory fallback, dry-run unless --install, --write-lock, or --run
  image-install.sh    # runs inside the image build
  entry.sh            # forces Rector --dry-run and a phpcbf diff
```

## Container

The image is the primary way to run the tools. It is built on a PHP 8.4 CLI base so the tools have the runtime they need even when the application does not. `run.sh` starts the container with:

- `--pids-limit 256`, `--memory 2g`, and `--cpus 2` (override with `--pids-limit`, `--memory`, and `--cpus`)
- `--network none`
- the application mounted read-only (`--mount type=bind,src=<app>,dst=/app,readonly`) and the report directory at `dst=/out` (paths that contain `,` or `:` are refused)
- one output directory mounted writable at `/out`
- `--read-only` and tmpfs on `/tmp` and `/var/tmp` (`noexec,nosuid,nodev`)
- `--cap-drop ALL` and `--security-opt no-new-privileges`
- `--rm` and a non-root user (uid 10001 in the image, or the caller's uid when that uid is not 0)
- no secrets and no host Composer config

Docker and Podman both accept these flags. `build.sh` and `run.sh` use `docker` when it is on `PATH`, otherwise `podman`. `--runtime docker` or `--runtime podman` overrides that.

Rector always receives `--dry-run`. Its cache file is `/tmp/rector.cache`. `phpcbf` is rewritten to `phpcs --report=diff` and writes `/out/phpcs.diff`. The wrapper does not apply either diff. A person, in the reviewed implementation step, applies a patch from the output directory after reading it. This skill does not write that patch into the application.

The image's PHPUnit binary runs only code that already executes on PHP 8.4. A suite that must prove behavior on PHP 5.3 still runs on PHP 5.3, outside this image.

## Build, version, and an internal registry

`scripts/toolchain/build.sh` prints the engine command and does not build. `--build` runs it. The script does not push.

```bash
scripts/toolchain/build.sh
scripts/toolchain/build.sh --build
scripts/toolchain/build.sh --tag registry.example/f-refactor-toolchain:a74fa99cc8638d34a8ab039c051ce5e5 --build
```

The dry-run prints `suggested-tag:` from `composer.lock`'s `content-hash`. Use that hash, or the date you rebuilt, as the tag you push. Do not retag a changed lock as an existing name.

```bash
docker tag f-refactor-toolchain:local registry.example/f-refactor-toolchain:<content-hash>
docker push registry.example/f-refactor-toolchain:<content-hash>
```

Podman uses the same `tag` and `push` verbs. Point `run.sh --image` at the tag you pushed. This skill does not log into a registry and does not store credentials.

### Base image digest

The default `ARG PHP_IMAGE` in `scripts/toolchain/Dockerfile` is the Docker Official Image `php:8.4-cli`, pinned by the manifest-list digest. `ARG COMPOSER_IMAGE` is the Docker Official Image `composer:2.8`, also pinned by digest. The image build copies `/usr/bin/composer` from that image. It does not download Composer with `curl`.

Pinned on 2026-10-28:

- `php@sha256:debadc2e36b857657846e2e952cbaf52702e55482dd3c2c43806f68d8c534a70` (`php:8.4-cli`)
- `composer@sha256:5248900ab8b5f7f880c2d62180e40960cd87f60149ec9a1abfd62ac72a02577c` (`composer:2.8`)

To move the pin:

1. `docker buildx imagetools inspect php:8.4-cli` and read the digest of the manifest list (the same value `docker buildx imagetools inspect` prints as the image digest, not one platform blob).
2. Confirm provenance: `docker buildx imagetools inspect php@sha256:<digest> --format '{{json .Provenance}}'`. The repository is the official `php` image.
3. Confirm the runtime: `docker run --rm --entrypoint php php@sha256:<digest> -v` reports PHP >= 8.4.3. Psalm 6 and the tool lock's platform pin need that.
4. Repeat for `composer:2.8` if that pin moves. The copied binary is only the Composer installer.
5. Replace the `ARG` defaults in the Dockerfile. `build.sh` reads those defaults. Rebuild with `--build`. The Dockerfile runs `composer audit --locked` and fails the build on advisories.

`--php-image` and `--composer-image` override the defaults for one build, so an internal registry can mirror the same images (`registry.example/php@sha256:...`). A base image without `@sha256:` is refused (exit 6). `--tag` and `run.sh --image` are refused when they start with `-` or fall outside a strict reference pattern, so a value cannot become an engine flag. Do not point these arguments at an image this skill has not described. The only names these docs use are the Docker Official Image `php`, the Docker Official Image `composer`, and a registry mirror the user configured for those two.

The Dockerfile installs `ca-certificates` and `unzip` with the base image's package manager (`apt-get` on the Debian php image) and then switches to user `toolchain` (uid 10001). An Alpine base is not the default. The `apt-get` line will not work there.

## One Composer source

The tool project has exactly one Composer source.

- Default: `https://repo.packagist.org`. `composer.json` has no `repositories` key, so Packagist stays the only source.
- Internal: an `https://` URL passed as `--composer-repo`. `packagist.org` is set to `false` in that tool project's `composer.json`, and one `type: composer` repository remains. `build.sh` prints `packagist.org: disabled`.

```bash
scripts/toolchain/build.sh --composer-repo https://composer.example.test
```

`http://`, a URL with a user or a query, a path repository, a VCS repository, and a second repository are refused (exit 6). Host global Composer config must be packagist.org only, or exactly that same internal source. `COMPOSER`, `COMPOSER_DISABLE_TLS`, `COMPOSER_CAFILE`, and `SSL_CERT_FILE` are refused. `COMPOSER_HOME` is a warning because that directory is part of the host check. `COMPOSER_AUTH` in the environment is refused.

An internal repository may need auth at build time. Pass `--composer-auth-file` pointing at a regular file. `build.sh --build` mounts it as the BuildKit secret `composer_auth` (`--secret id=composer_auth,src=...`). The Dockerfile reads that file inside one `RUN` and deletes Composer home in the same `RUN`. The value is not a build arg, not an `ENV`, and not printed. `DOCKER_BUILDKIT=1` is required for `docker build --secret`. Podman accepts the same `--secret` flag. Do not `COPY` the file into the image.

With packagist.org, package `dist` URLs in the lock are zipballs on `api.github.com` (and the same family of HTTPS hosts Composer records). Those URLs are how `composer install` downloads the tools. An internal source that cannot reach GitHub cannot use that lock. `--write-lock` against the internal URL rebuilds the lock so every dist host is the internal repository. `--composer-repo` pointing at an internal host refuses a lock whose dist hosts are elsewhere (exit 6). The committed lock in this skill stays the packagist lock. `--write-lock` copies the tool project to `$XDG_DATA_HOME/f-refactor-tools/lock-work` (or to `--toolchain-dir` outside this skill) and writes the lock there. It does not edit `scripts/toolchain/composer.json`.

## Lock

The tool project's `composer.lock` is required before a build or a host install. Without it, `composer update` or `composer require` would resolve the whole tool tree. Dry-run and `--build` both refuse a missing lock:

`no composer.lock in the tool project; resolving dependencies would select every package version; create the lock with --write-lock and explicit approval first`

Creating or refreshing the lock is explicit:

```bash
scripts/toolchain/build.sh --write-lock
```

That runs `composer update --no-install` in the tool directory only, then `composer audit --locked`. It does not run unless `--write-lock` is passed. Review the lock diff and commit `composer.lock` with `composer.json`. Audit findings fail the command (exit 5) and are not ignored. The lock file is still written so it can be reviewed.

For an internal source, run `--write-lock` with `--toolchain-dir` set to a copy of the tool project that is allowed to record that URL. The script writes `packagist.org: false` and the one repository into that copy's `composer.json`, then updates the lock. Dist URLs in the new lock must use that repository's host.

`composer install` inside the image and in the host fallback uses the lock (`--no-plugins --no-scripts --no-interaction --prefer-dist`). It is not a bare `composer update`.

## Run

Ask, then:

```bash
scripts/toolchain/run.sh --help
scripts/toolchain/run.sh --app /path/to/app --out /path/to/reports -- phpstan analyse src
scripts/toolchain/run.sh --app /path/to/app --out /path/to/reports --run -- phpstan analyse src
```

Dry-run prints the engine command, including `--network none` and the `:ro` mount, and does not start a container. `--run` executes it and writes the combined log to `<out>/<tool>.log`.

| Tool | Command after `--` | Report |
|------|--------------------|--------|
| PHPStan | `phpstan analyse src` | `<out>/phpstan.log` |
| Psalm | `psalm` | `<out>/psalm.log` |
| Rector | `rector process src` | `<out>/rector.log`. The engine command includes `--dry-run`. |
| PHP_CodeSniffer | `phpcs --standard=/opt/toolchain/vendor/phpcompatibility/php-compatibility/PHPCompatibility --runtime-set testVersion 5.6-8.3 src` | `<out>/phpcs.log` |
| phpcbf | `phpcbf src` | Rewritten to a diff at `/out/phpcs.diff` (the host's `<out>/phpcs.diff`). |
| Deptrac | `deptrac analyse` | `<out>/deptrac.log` |
| PHPUnit | `phpunit --filter <seam>` | `<out>/phpunit.log`. Only for a suite that runs on PHP 8.4. |

`testVersion` is a range from the current production minor to the hop target, for example `5.6-7.4`. PHPCompatibility 9.3.5 (the release on the `^9.3` line, published in 2019) has sniffs through PHP 7.4 and no sniffs for PHP 8.x changes. A `testVersion` that includes 8.x does not detect 8.x breaks. For those, use a Rector PHP set for the hop, PHPStan or Psalm with the language level set to the target, and the test suite on the target runtime. PHPCompatibility 10.x is a pre-release. It is not installed by default and is not added without an explicit approval and a new tool lock. The standard path is inside the image. The project is not given a Composer plugin to register it. If the application already has its own PHP_CodeSniffer 4, this image does not downgrade it: the image carries PHP_CodeSniffer `^3.13` only, and the application's pin is untouched. PHPCompatibility 9 does not run on PHP_CodeSniffer `^4` or `>=4`.

Stdout of a dry-run Rector is the diff to review. Applying it is a later reviewed change, not `--run`.

## Host programs

| Mode | Host programs | Not required on the host |
|------|----------------|--------------------------|
| `build.sh` dry-run and `--build` | `python3` to read the tool project. `--build` also needs `docker` or `podman` | PHP, Composer. Those run inside the image |
| `build.sh --write-lock` | `python3`, PHP, and Composer | A container engine |
| `run.sh` dry-run | A shell | PHP, Composer, and a container engine |
| `run.sh --run` | `docker` or `podman` | PHP and Composer |
| `install-host.sh` | `python3`. `--install`, `--write-lock`, and `--run` also need PHP >= 8.4.3 and Composer | A container engine |

## Host fallback

Use this when no container engine is available. The tools still do not go into the application.

This mode has no sandbox. The process can use the network, and the application tree is a normal writable directory. Rector is still forced to `--dry-run`, and `phpcbf` is still rewritten to a diff, but nothing mounts the tree read-only and nothing sets `--network none`. Prefer `run.sh` when an engine is available.

```bash
scripts/toolchain/install-host.sh
scripts/toolchain/install-host.sh --install
scripts/toolchain/install-host.sh --name ci --install
scripts/toolchain/install-host.sh --app /path/to/app --out /path/to/reports -- phpstan analyse src
```

The default directory is `${XDG_DATA_HOME:-$HOME/.local/share}/f-refactor-tools/<name>` with `<name>` defaulting to `default`. `--tools-dir` overrides it. The directory must be outside the application tree.

`--install` copies the tool `composer.json` and `composer.lock` into that directory and runs `composer install` there. The host PHP must be >= 8.4.3, because that is the platform the lock was solved for. PHP 5.3 on the host cannot execute these binaries. Keep the old runtime for the application's own tests.

`--run` uses `<tools-dir>/vendor/bin` and the same Rector and phpcbf rewriting. There is no `--network none` and no read-only mount in this mode. That is why the container is primary.

## What the agent runs

Detect what the application CI already runs. A check the repository already executes still counts. Do not add a dev dependency to the application to reproduce it. For a tool the application cannot run, use this toolchain after the user accepts the run.

The agent selects the seam, runs the tool, and writes the command and the result into the step record or the inventory. Interpretation stops at what the tool printed.

The agent does not treat a green Rector run as a behavior proof, a PHPStan baseline as permission to edit unrelated errors, or a missing tool as a passed check. Characterization oracles and golden masters are the behavior gate. Static tools are the mechanical gate. Both have to pass. A Composer resolution failure in the application is not fixed by `--ignore-platform-reqs`.

## Tools

| Tool | Phase | What it decides | Example | How to read it |
|------|-------|-----------------|---------|----------------|
| Rector | `execute` (a migration hop or a codemod) | Mechanical diff for one rule set | `scripts/toolchain/run.sh --app <app> --out <out> -- rector process src` | The wrapper adds `--dry-run`. Review the diff under `<out>`. One set per PR. A clean run is not proof that behavior held. An unexpected edit stops the step. Do not apply the diff here. Phalcon C-extension classes are invisible without stubs. |
| PHPCompatibility on PHP_CodeSniffer | `inventory`, `plan`, `execute` for a migration | Source that will not run on PHP versions through 7.4 | `scripts/toolchain/run.sh --app <app> --out <out> -- phpcs --standard=/opt/toolchain/vendor/phpcompatibility/php-compatibility/PHPCompatibility --runtime-set testVersion 5.6-7.4 src` | 9.3.5 covers up to PHP 7.4, not PHP 8. Use a range that ends at 7.4 when the current runtime is older. Errors are forced-fix candidates. Confirm each one against the migration guide fetched for that hop. Do not silence a sniff to go green. PHP 8 breaks come from Rector, PHPStan or Psalm, and the tests on the target runtime. |
| PHPStan or Psalm | `execute` | New static errors against the committed baseline | `scripts/toolchain/run.sh --app <app> --out <out> -- phpstan analyse` or `psalm` | New errors fail the step. Do not clear baseline entries as a side effect. Set the language level to the target on a migration and to the current runtime on a refactor. |
| Deptrac | `plan` and `execute` for a refactor boundary | Whether a new module boundary holds | `scripts/toolchain/run.sh --app <app> --out <out> -- deptrac analyse` | A new violation fails the step. Add a rule only for the boundary this step introduces. The package is `deptrac/deptrac`. |
| PHPUnit, including golden masters | `safety-net` (the plan, via `f-testing`) and `execute` | Observed behavior at the seam | The application's PHPUnit on the runtime that claim is about. The image binary only when that runtime is PHP 8.4. | Tests must pass on the unchanged code before the edit. A migration runs the suite on the old runtime and the target and diffs normalized output. Do not edit the expected value. |
| Composer `why-not` | `inventory`, `plan` | Which application packages block the target PHP | `composer why-not php <target>` in the application | A blocking package is a migration fact. Replacing it needs approval. This does not install tools. |
| Composer `audit` | `inventory`, `close-out`, and after a tool-lock write | Known advisories | `composer audit` in the application. `composer audit --locked` in the tool project | Findings are recorded. The tool-project audit failure stops the build (exit 5). |
| Git history | `inventory`, `prioritize` | Where churn is, inside a security tier | `git log --since=<window> --pretty=format: --name-only` | Record the command and the window. High churn on the planned path is a tie-break. |
| CI version matrix | `plan`, `execute`, `close-out` | The suite on the production runtime and the hop target | The repository's existing CI config | Add the hop target next to the current production runtime. A red job fails the step. |

`phalcon/ide-stubs` is allowlisted but not in the default tool `composer.json`. Adding it is a `--write-lock` change with a `^MAJOR.MINOR` constraint (`^3.4`, `^4.0`, or `^5.0`). It is not a gate.

## Supply chain

Direct requirements in the tool `composer.json` must be on this list, each with a `^MAJOR.MINOR` constraint. `php` must be `>=8.4.3` or `^8.4`. `require-dev` is refused. Abandoned names are refused.

| Tool | Packagist name | Not accepted |
|------|----------------|--------------|
| Rector | `rector/rector` | Any other Rector package or fork |
| PHPStan | `phpstan/phpstan` | |
| Psalm | `vimeo/psalm` | |
| Deptrac | `deptrac/deptrac` | `qossmic/deptrac` |
| PHP_CodeSniffer | `squizlabs/php_codesniffer` | `phpcsstandards/php_codesniffer`. The GitHub repository is `PHPCSStandards/PHP_CodeSniffer`. |
| PHPCompatibility | `phpcompatibility/php-compatibility` | |
| PHPUnit | `phpunit/phpunit` | |
| Phalcon stubs | `phalcon/ide-stubs` | Optional. Not in the default lock. |

Names were checked on 2026-10-27 against each project's README. The default constraints, solved for PHP 8.4.3, are:

| Package | Constraint |
|---------|------------|
| `rector/rector` | `^2.0` |
| `phpstan/phpstan` | `^2.0` |
| `vimeo/psalm` | `^6.0` |
| `deptrac/deptrac` | `^4.0` |
| `squizlabs/php_codesniffer` | `^3.13` |
| `phpcompatibility/php-compatibility` | `^9.3` |
| `phpunit/phpunit` | `^13.0` |

- `secure-http` stays `true`. `disable-tls` stays `false`.
- One source only. A mirror, a path repository, a VCS repository, or a second URL is exit 6. An internal source disables packagist.org in the tool project.
- The tool `composer.lock` must already exist, except during `--write-lock`. Commit it and review the diff.
- Install and audit use `--no-plugins --no-scripts --no-interaction`. Audit uses `--locked`.
- No `curl \| sh`, no PHAR download, no `composer global`, no `--ignore-platform-reqs`.
- Auth and custom CA material are not taken from the environment. Build-time auth is a BuildKit secret. It is not written into a layer.

Exit codes: `0` plan, build, install, or a clean tool run; `1` bad usage; `2` a required program, directory, or engine is missing; `3` `composer` or the engine failed; `5` `composer audit` reported advisories; `6` the source, lock, TLS setting, auth channel, or package is outside this rule. A tool's own non-zero status is passed through by `run.sh --run`.

## Troubleshooting

- **Build cannot reach packagist.org.** Use `--composer-repo https://...` and `--write-lock` so the lock's dist hosts are that repository. Do not point a packagist lock at an internal repo.
- **`--build` says the lock is missing or the dist host does not match.** The refusal is the lock check. Create the lock with `--write-lock` against the same `--composer-repo`.
- **Audit exit 5.** Read the advisory list. Do not add an ignore. Remove the package or wait for a release, then `--write-lock` again.
- **`docker build` does not accept `--secret`.** Set `DOCKER_BUILDKIT=1`, or use Podman. Do not switch the secret to a build arg.
- **Container user cannot write `/out`.** The mount is the host path given to `--out`. On a rootless engine, the `--user` value must be allowed to write that directory.
- **Rector or PHPStan tries to write inside the application.** The mount is `:ro`. Cache belongs under `/tmp`. Do not remove `--read-only` or `:ro`.
- **Host install says the PHP platform is too old.** The fallback needs PHP >= 8.4.3 on `PATH`. Use the container instead of changing the application's `config.platform.php`.
- **The tool directory was refused.** It overlaps the application tree. Pick a path outside that repo.
- **A global Composer repository changed the resolve.** Clear the extra global repository or point `COMPOSER_HOME` at an empty directory and pass that warning. The script refuses a global source that is not packagist.org and not the one configured URL.
