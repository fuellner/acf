#!/usr/bin/env bash
# Optional installer for the f-refactor toolchain.
#
# Adds selected tools as Composer dev dependencies of one existing project.
# Dry-run unless --install. Never installs globally, never edits require,
# never edits config.platform.php, and never deploys.
#
# Supply chain: Composer from https://repo.packagist.org only. The package
# allowlist is in spec_is_allowed. No PHARs, curl, wget, mirrors, or images.
#
# Ask the user before running this, including a dry-run.
# Licenses: ../references/tool-licenses.md
# Usage and version picks: ../references/toolchain.md
set -euo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
licenses_file=$(CDPATH='' cd -- "$script_dir/../references" && pwd)/tool-licenses.md

mode="dry-run"
project_dir="."
phalcon_major=""
tool_lines=""
phpcs_implied=0

usage() {
  cat <<'EOF'
Usage: install-tools.sh [options] [tool ...]

Add f-refactor tools as Composer dev dependencies (require-dev) of one
project. Nothing is installed globally. require, config.platform.php, and
production are left untouched.

Dry-run is the default: the script prints the composer require --dev command
and does not change the project. Pass --install to run that command.

Ask a person before running this script.

Options:
  --help, -h           Show this help
  --dry-run            Print the plan only (default)
  --install            Run composer require --dev for the packages below
  --project-dir DIR    Project that contains composer.json (default: .)
  --all                rector, phpstan, deptrac, phpcs, phpcompatibility, phpunit
  --rector             rector/rector
  --phpstan            phpstan/phpstan
  --psalm              vimeo/psalm (alternative to PHPStan; not in --all)
  --deptrac            deptrac/deptrac
  --phpcs              squizlabs/php_codesniffer
  --phpcompatibility   phpcompatibility/php-compatibility, and PHP_CodeSniffer
                       when it is not already a dev dependency
  --phpunit            phpunit/phpunit
  --phalcon-stubs N    phalcon/ide-stubs for extension major 3, 4, or 5

Tools already listed in composer.json are skipped. A package already in
require is not moved and not upgraded. On a composer platform older than a
tool can run (PHP 5.3 is the usual case), the tool is skipped. Use a separate
modern PHP toolchain and point it at the legacy tree. Do not pass
--ignore-platform-reqs and do not raise config.platform.php to force an install.

The constraint is the newest supported major this script knows that declares
support for the composer platform PHP (config.platform.php when set, otherwise
the php on PATH). Only ^MAJOR.MINOR constraints on the packagist.org allowlist
are passed to Composer. Composer picks the latest release inside that constraint.

Packages come only from https://repo.packagist.org over HTTPS. secure-http must
stay true and disable-tls must stay false. Project and global Composer
repositories are checked. A mirror, a path repository, or a VCS repository is
refused. composer.lock must already exist. Without it, composer require
resolves every dependency, including production packages. Dry-run and
--install both refuse a missing lock. composer require updates composer.lock
for the added packages only. composer audit --locked runs after an install.
Commit composer.lock and review the lock diff before committing.

COMPOSER_HOME is a warning: global config from that directory is still checked.
COMPOSER_CAFILE, SSL_CERT_FILE, and COMPOSER_AUTH are refused. They can
redirect TLS trust or auth outside the repository list.

Exit codes:
  0  Plan printed, or install finished and audit reported nothing. Includes "already present".
  1  Bad usage (no tools, unknown tool, missing flag value)
  2  php, composer, or composer.json missing, or composer older than 2.4
  3  composer require failed
  4  Nothing was added, and every selected tool was refused
     (this PHP cannot run it, or an existing pin must not be changed)
  5  require-dev was updated and composer audit reported advisories or failed
  6  Refused: package, TLS, repository (project or global), trust or auth
     environment, or a missing composer.lock is outside the packagist.org rule

Examples:
  install-tools.sh --project-dir /path/to/app --phpstan --phpunit
  install-tools.sh --project-dir /path/to/app --all
  install-tools.sh --project-dir /path/to/app --install --phpcs --phpcompatibility
  install-tools.sh --project-dir /path/to/legacy --phalcon-stubs 4
EOF
}

die() {
  local code="$1"
  shift
  printf 'error: %s\n' "$*" >&2
  exit "$code"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

has_tool() {
  case "
$tool_lines" in
    *"
$1
"*) return 0 ;;
    *) return 1 ;;
  esac
}

add_tool() {
  if has_tool "$1"; then
    return 0
  fi
  tool_lines="${tool_lines}${1}"$'\n'
}

lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_ver() {
  local raw="$1" core maj min pat
  if [[ "$raw" =~ ^([0-9]+(\.[0-9]+)*) ]]; then
    core="${BASH_REMATCH[1]}"
  else
    printf ''
    return 0
  fi
  maj="${core%%.*}"
  if [[ "$core" == *.* ]]; then
    min="${core#*.}"
    min="${min%%.*}"
  else
    min=0
  fi
  case "$core" in
    *.*.*) pat="${core#*.*.}" ; pat="${pat%%.*}" ;;
    *) pat=0 ;;
  esac
  printf '%s.%s.%s' "$maj" "$min" "$pat"
}

# Prints -1, 0, or 1. Empty input is an error for the caller.
ver_cmp() {
  local left right la lb lc ra rb rc
  left=$(normalize_ver "$1")
  right=$(normalize_ver "$2")
  la="${left%%.*}"
  ra="${right%%.*}"
  lb="${left#*.}"
  lb="${lb%%.*}"
  rb="${right#*.}"
  rb="${rb%%.*}"
  lc="${left##*.}"
  rc="${right##*.}"
  if ((10#$la > 10#$ra)); then printf '%s\n' 1 ; return 0 ; fi
  if ((10#$la < 10#$ra)); then printf '%s\n' '-1' ; return 0 ; fi
  if ((10#$lb > 10#$rb)); then printf '%s\n' 1 ; return 0 ; fi
  if ((10#$lb < 10#$rb)); then printf '%s\n' '-1' ; return 0 ; fi
  if ((10#$lc > 10#$rc)); then printf '%s\n' 1 ; return 0 ; fi
  if ((10#$lc < 10#$rc)); then printf '%s\n' '-1' ; return 0 ; fi
  printf '%s\n' 0
}

ver_ge() {
  local cmp
  [[ -n "$(normalize_ver "$1")" && -n "$(normalize_ver "$2")" ]] || return 1
  cmp=$(ver_cmp "$1" "$2")
  [[ "$cmp" != "-1" ]]
}

package_for() {
  case "$1" in
    rector) printf 'rector/rector' ;;
    phpstan) printf 'phpstan/phpstan' ;;
    psalm) printf 'vimeo/psalm' ;;
    deptrac) printf 'deptrac/deptrac' ;;
    phpcs) printf 'squizlabs/php_codesniffer' ;;
    phpcompatibility) printf 'phpcompatibility/php-compatibility' ;;
    phpunit) printf 'phpunit/phpunit' ;;
    phalcon-stubs) printf 'phalcon/ide-stubs' ;;
    *) return 1 ;;
  esac
}

license_of() {
  case "$1" in
    rector/rector|phpstan/phpstan|vimeo/psalm|deptrac/deptrac) printf 'MIT' ;;
    squizlabs/php_codesniffer|phpunit/phpunit|phalcon/ide-stubs) printf 'BSD-3-Clause' ;;
    phpcompatibility/php-compatibility) printf 'LGPL-3.0-or-later' ;;
    *) printf 'unknown' ;;
  esac
}

# Official packagist.org names, checked 2026-10-27 against each project's README
# and the Packagist repository URL. phpcsstandards/php_codesniffer is abandoned
# and points at squizlabs/php_codesniffer. qossmic/deptrac is abandoned and points
# at deptrac/deptrac. Neither abandoned name is allowed.
spec_is_allowed() {
  local spec="$1" name constraint
  name="${spec%%:*}"
  constraint="${spec#*:}"
  case "$name" in
    phpcsstandards/php_codesniffer)
      die 6 "Refusing phpcsstandards/php_codesniffer. Packagist marks it abandoned. The official package is squizlabs/php_codesniffer."
      ;;
    qossmic/deptrac)
      die 6 "Refusing qossmic/deptrac. Packagist marks it abandoned. The official package is deptrac/deptrac."
      ;;
    rector/rector|phpstan/phpstan|vimeo/psalm|deptrac/deptrac|squizlabs/php_codesniffer|phpcompatibility/php-compatibility|phpunit/phpunit|phalcon/ide-stubs)
      ;;
    *)
      die 6 "Refusing package ${name}. It is not on the packagist.org allowlist."
      ;;
  esac
  if [[ ! "$constraint" =~ ^\^[0-9]+\.[0-9]+$ ]]; then
    die 6 "Refusing ${spec}. Only a supported major constraint (^MAJOR.MINOR) is accepted."
  fi
  case "$spec" in
    *://*|*'git@'*|*'dev-'*|*'@'*|*\**)
      die 6 "Refusing ${spec}. URLs, forks, dev branches, and wildcards are not accepted."
      ;;
  esac
}

# Reads repository JSON on stdin. Exit 0 only for "no extra repository" or
# exactly https://repo.packagist.org. Anything else can substitute a package.
repo_json_is_packagist_only() {
  php -r "$(cat <<'PHP'
$raw = stream_get_contents(STDIN);
$data = json_decode($raw, true);
if (!is_array($data)) {
    fwrite(STDERR, "repository config is not a JSON object or list\n");
    exit(1);
}
$entries = array();
$index = 0;
$list = true;
foreach ($data as $key => $value) {
    if ($key !== $index) {
        $list = false;
        break;
    }
    $index++;
}
if ($list) {
    $entries = $data;
} else {
    foreach ($data as $key => $value) {
        if (($key === "packagist.org" || $key === "packagist") && $value === false) {
            fwrite(STDERR, "packagist.org is disabled\n");
            exit(1);
        }
        if (!is_array($value)) {
            fwrite(STDERR, "unexpected repository entry\n");
            exit(1);
        }
        if (array_key_exists("packagist.org", $value) && $value["packagist.org"] === false) {
            fwrite(STDERR, "packagist.org is disabled\n");
            exit(1);
        }
        $entries[] = $value;
    }
}
foreach ($entries as $entry) {
    if (!is_array($entry)) {
        fwrite(STDERR, "repository entry is not an object\n");
        exit(1);
    }
    if (isset($entry["packagist.org"]) && $entry["packagist.org"] === false) {
        fwrite(STDERR, "packagist.org is disabled\n");
        exit(1);
    }
    if (!isset($entry["type"], $entry["url"]) || $entry["type"] !== "composer" || $entry["url"] !== "https://repo.packagist.org") {
        fwrite(STDERR, "repository is not https://repo.packagist.org\n");
        exit(1);
    }
    foreach ($entry as $key => $value) {
        if ($key !== "type" && $key !== "url") {
            fwrite(STDERR, "repository entry has extra options\n");
            exit(1);
        }
    }
}
exit(0);
PHP
)"
}

assert_lockfile() {
  if [[ -f "$project_dir/composer.lock" ]]; then
    return 0
  fi
  die 6 "no composer.lock; a require would resolve every dependency; create the lock with explicit approval first"
}

assert_supply_chain() {
  local secure tls repos_json global_repos repo_err file_err
  if [[ -n "${COMPOSER:-}" ]]; then
    die 6 "Refusing install: COMPOSER is set. Unset it so Composer uses this project's composer.json."
  fi
  case "${COMPOSER_DISABLE_TLS:-}" in
    1|true|TRUE|yes|YES)
      die 6 "Refusing install: COMPOSER_DISABLE_TLS is set. Composer must use HTTPS."
      ;;
  esac
  if [[ -n "${COMPOSER_HOME:-}" ]]; then
    warn "COMPOSER_HOME is set. Global Composer config from that directory is included in the repository check. Unset it when you mean the default Composer home."
  fi
  if [[ -n "${COMPOSER_CAFILE:-}" ]]; then
    die 6 "Refusing install: COMPOSER_CAFILE is set. A custom CA file can redirect HTTPS trust. Unset it."
  fi
  if [[ -n "${SSL_CERT_FILE:-}" ]]; then
    die 6 "Refusing install: SSL_CERT_FILE is set. A custom CA file can redirect HTTPS trust. Unset it."
  fi
  if [[ -n "${COMPOSER_AUTH:-}" ]]; then
    die 6 "Refusing install: COMPOSER_AUTH is set. Inline auth can point Composer at another host. Unset it."
  fi
  secure=$(composer --no-interaction --no-plugins --working-dir "$project_dir" config secure-http 2>/dev/null) || die 6 "Could not read Composer secure-http."
  tls=$(composer --no-interaction --no-plugins --working-dir "$project_dir" config disable-tls 2>/dev/null) || die 6 "Could not read Composer disable-tls."
  if [[ "$secure" != "true" ]]; then
    die 6 "Refusing install: Composer secure-http is ${secure}. It must be true. This script will not disable TLS."
  fi
  if [[ "$tls" != "false" ]]; then
    die 6 "Refusing install: Composer disable-tls is ${tls}. It must be false."
  fi
  global_repos=$(composer --no-interaction --no-plugins config --global --json repositories 2>/dev/null) || die 6 "Could not read global Composer repositories."
  if ! repo_err=$(printf '%s' "$global_repos" | repo_json_is_packagist_only 2>&1); then
    die 6 "Refusing global Composer repositories (${repo_err}). Only https://repo.packagist.org is accepted. No mirrors, path repos, or forks."
  fi
  repos_json=$(composer --no-interaction --no-plugins --working-dir "$project_dir" config --json repositories 2>/dev/null) || die 6 "Could not read Composer repositories."
  if ! repo_err=$(printf '%s' "$repos_json" | repo_json_is_packagist_only 2>&1); then
    die 6 "Refusing Composer repositories (${repo_err}). Only https://repo.packagist.org is accepted. No mirrors, path repos, or forks."
  fi
  if ! file_err=$(php -r "$(cat <<'PHP'
$data = json_decode(file_get_contents($argv[1]), true);
if (!is_array($data)) {
    fwrite(STDERR, "composer.json is not a JSON object\n");
    exit(1);
}
$config = array();
if (isset($data["config"]) && is_array($data["config"])) {
    $config = $data["config"];
}
if (array_key_exists("secure-http", $config) && $config["secure-http"] !== true) {
    fwrite(STDERR, "composer.json config.secure-http is not true\n");
    exit(1);
}
if (array_key_exists("disable-tls", $config) && $config["disable-tls"] !== false) {
    fwrite(STDERR, "composer.json config.disable-tls is not false\n");
    exit(1);
}
if (!array_key_exists("repositories", $data)) {
    exit(0);
}
$repos = $data["repositories"];
if (!is_array($repos)) {
    fwrite(STDERR, "composer.json repositories is not an object or list\n");
    exit(1);
}
$entries = array();
$index = 0;
$list = true;
foreach ($repos as $key => $value) {
    if ($key !== $index) {
        $list = false;
        break;
    }
    $index++;
}
if ($list) {
    $entries = $repos;
} else {
    foreach ($repos as $key => $value) {
        if (($key === "packagist.org" || $key === "packagist") && $value === false) {
            fwrite(STDERR, "composer.json disables packagist.org\n");
            exit(1);
        }
        if (!is_array($value)) {
            fwrite(STDERR, "composer.json has an unexpected repository entry\n");
            exit(1);
        }
        $entries[] = $value;
    }
}
foreach ($entries as $entry) {
    if (!is_array($entry)) {
        fwrite(STDERR, "composer.json repository entry is not an object\n");
        exit(1);
    }
    if (isset($entry["packagist.org"]) && $entry["packagist.org"] === false) {
        fwrite(STDERR, "composer.json disables packagist.org\n");
        exit(1);
    }
    if (isset($entry["packagist"]) && $entry["packagist"] === false) {
        fwrite(STDERR, "composer.json disables packagist\n");
        exit(1);
    }
    if (!isset($entry["type"], $entry["url"]) || $entry["type"] !== "composer" || $entry["url"] !== "https://repo.packagist.org") {
        fwrite(STDERR, "composer.json repository is not https://repo.packagist.org\n");
        exit(1);
    }
}
exit(0);
PHP
)" "$composer_json" 2>&1); then
    die 6 "Refusing composer.json (${file_err})."
  fi
  printf 'supply-chain: packagist.org only, HTTPS required, allowlisted packages only.\n'
}

# Keep this in step with the installer table in references/toolchain.md.
# CONSTRAINT is the composer require spec, or empty when the tool is refused.
# REASON is why it was refused. NOTE is a warning that still allows install.
choose_constraint() {
  local tool="$1"
  CONSTRAINT=""
  REASON=""
  NOTE=""
  case "$tool" in
    rector)
      if ver_ge "$platform" 7.4.0; then CONSTRAINT="rector/rector:^2.0"
      elif ver_ge "$platform" 7.2.0; then CONSTRAINT="rector/rector:^1.2"
      else REASON="Rector needs PHP >= 7.2. Platform is ${platform}."
      fi
      ;;
    phpstan)
      if ver_ge "$platform" 7.4.0; then CONSTRAINT="phpstan/phpstan:^2.0"
      elif ver_ge "$platform" 7.2.0; then CONSTRAINT="phpstan/phpstan:^1.12"
      else REASON="PHPStan needs PHP >= 7.2. Platform is ${platform}."
      fi
      ;;
    psalm)
      if ver_ge "$platform" 8.6.0; then
        REASON="No Psalm constraint in this script declares PHP >= 8.6. Platform is ${platform}."
      elif ver_ge "$platform" 8.4.0; then
        if ver_ge "$platform" 8.4.3; then CONSTRAINT="vimeo/psalm:^6.0"
        else REASON="Psalm 6 requires PHP >= 8.4.3 on the 8.4 line, and Psalm 5 does not support 8.4. Platform is ${platform}."
        fi
      elif ver_ge "$platform" 7.4.0; then CONSTRAINT="vimeo/psalm:^5.26"
      elif ver_ge "$platform" 7.1.0; then CONSTRAINT="vimeo/psalm:^4.30"
      else REASON="Psalm needs PHP >= 7.1. Platform is ${platform}."
      fi
      ;;
    deptrac)
      if ver_ge "$platform" 9.0.0; then
        REASON="deptrac/deptrac ^4 allows PHP ^8.2 only. Platform is ${platform}."
      elif ver_ge "$platform" 8.2.0; then CONSTRAINT="deptrac/deptrac:^4.0"
      elif ver_ge "$platform" 8.1.0; then CONSTRAINT="deptrac/deptrac:^3.0"
      else REASON="Deptrac needs PHP >= 8.1. The abandoned qossmic/deptrac package is not installed. Platform is ${platform}."
      fi
      ;;
    phpcs)
      if ver_ge "$platform" 5.4.0; then CONSTRAINT="squizlabs/php_codesniffer:^3.13"
      else REASON="PHP_CodeSniffer 3 needs PHP >= 5.4. PHP_CodeSniffer 2 is not installed. Platform is ${platform}."
      fi
      ;;
    phpcompatibility)
      if ver_ge "$platform" 5.4.0; then CONSTRAINT="phpcompatibility/php-compatibility:^9.3"
      else REASON="PHPCompatibility 9 with PHP_CodeSniffer 3 needs PHP >= 5.4. Platform is ${platform}."
      fi
      ;;
    phpunit)
      if ver_ge "$platform" 8.4.1; then CONSTRAINT="phpunit/phpunit:^13.0"
      elif ver_ge "$platform" 8.3.0; then CONSTRAINT="phpunit/phpunit:^12.0"
      elif ver_ge "$platform" 8.2.0; then CONSTRAINT="phpunit/phpunit:^11.0"
      elif ver_ge "$platform" 8.1.0; then CONSTRAINT="phpunit/phpunit:^10.5"
      elif ver_ge "$platform" 7.3.0; then CONSTRAINT="phpunit/phpunit:^9.6"
      elif ver_ge "$platform" 7.2.0; then CONSTRAINT="phpunit/phpunit:^8.5"
      elif ver_ge "$platform" 7.1.0; then CONSTRAINT="phpunit/phpunit:^7.5"
      else REASON="No supported PHPUnit major runs on PHP ${platform}. This script does not install PHPUnit 4, 5, or 6."
      fi
      ;;
    phalcon-stubs)
      case "$phalcon_major" in
        5)
          if ver_ge "$platform" 8.1.0; then CONSTRAINT="phalcon/ide-stubs:^5.0"
          else REASON="phalcon/ide-stubs 5.x needs PHP >= 8.1. Platform is ${platform}."
          fi
          ;;
        4)
          if ver_ge "$platform" 7.2.0; then CONSTRAINT="phalcon/ide-stubs:^4.0"
          else REASON="phalcon/ide-stubs 4.x needs PHP >= 7.2. Platform is ${platform}."
          fi
          ;;
        3)
          CONSTRAINT="phalcon/ide-stubs:^3.4"
          NOTE="phalcon/ide-stubs 3.4.3 publishes no PHP requirement. Confirm the major matches the extension before --install."
          ;;
        *)
          REASON="--phalcon-stubs needs major 3, 4, or 5."
          ;;
      esac
      ;;
    *)
      REASON="Unknown tool ${tool}."
      ;;
  esac
}

accept_tool_name() {
  case "$1" in
    rector|phpstan|psalm|deptrac|phpcs|phpcompatibility|phpunit) add_tool "$1" ;;
    phalcon-stubs)
      die 1 "Pass --phalcon-stubs with the extension major (3, 4, or 5). It is not included in --all."
      ;;
    *)
      die 1 "Unknown tool: $1. Use --help for the list."
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage ; exit 0 ;;
    --dry-run) mode="dry-run" ; shift ;;
    --install) mode="install" ; shift ;;
    --project-dir)
      [[ $# -ge 2 ]] || die 1 "--project-dir needs a directory"
      project_dir="$2"
      shift 2
      ;;
    --project-dir=*)
      project_dir="${1#*=}"
      [[ -n "$project_dir" ]] || die 1 "--project-dir needs a directory"
      shift
      ;;
    --all)
      add_tool rector
      add_tool phpstan
      add_tool deptrac
      add_tool phpcs
      add_tool phpcompatibility
      add_tool phpunit
      shift
      ;;
    --rector|--phpstan|--psalm|--deptrac|--phpcs|--phpcompatibility|--phpunit)
      add_tool "${1#--}"
      shift
      ;;
    --phalcon-stubs)
      [[ $# -ge 2 ]] || die 1 "--phalcon-stubs needs a major version: 3, 4, or 5"
      phalcon_major="$2"
      add_tool phalcon-stubs
      shift 2
      ;;
    --phalcon-stubs=*)
      phalcon_major="${1#*=}"
      [[ -n "$phalcon_major" ]] || die 1 "--phalcon-stubs needs a major version: 3, 4, or 5"
      add_tool phalcon-stubs
      shift
      ;;
    --ignore-platform-reqs|--global|global)
      die 1 "Refusing $1. This script does not ignore the PHP platform and does not install globally."
      ;;
    --)
      shift
      break
      ;;
    --*)
      die 1 "Unknown option: $1"
      ;;
    *)
      accept_tool_name "$1"
      shift
      ;;
  esac
done

while [[ $# -gt 0 ]]; do
  accept_tool_name "$1"
  shift
done

if [[ -z "$tool_lines" ]]; then
  die 1 "No tools selected. Pass --all or name tools. --help lists them."
fi

if has_tool phalcon-stubs; then
  case "$phalcon_major" in
    3|4|5) ;;
    *) die 1 "--phalcon-stubs needs major 3, 4, or 5. Got: ${phalcon_major:-<empty>}" ;;
  esac
fi

if has_tool phpcompatibility && ! has_tool phpcs; then
  phpcs_implied=1
  # Rebuild so phpcs is planned before PHPCompatibility.
  raw_lines="$tool_lines"
  tool_lines=""
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    if [[ "$name" == "phpcompatibility" ]]; then
      add_tool phpcs
    fi
    add_tool "$name"
  done <<EOF
$raw_lines
EOF
fi

if ! command -v php >/dev/null 2>&1; then
  die 2 "php is not on PATH. Install a PHP CLI before adding dev tools. For a PHP 5.3 application, run this script on a newer PHP and keep behavior tests on 5.3."
fi
if ! command -v composer >/dev/null 2>&1; then
  die 2 "composer is not on PATH. Install Composer 2.4 or newer from https://getcomposer.org. This script does not download Composer."
fi

runtime_line=$(php -r 'echo PHP_VERSION;' 2>/dev/null) || die 2 "php -r failed"
runtime_php=$(normalize_ver "$runtime_line")
[[ -n "$runtime_php" ]] || die 2 "Could not parse php version from: $runtime_line"

composer_line=$(composer --version --no-ansi 2>&1) || die 2 "composer is not runnable: $composer_line"
if [[ "$composer_line" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  composer_ver="${BASH_REMATCH[1]}"
else
  die 2 "Could not parse composer version from: $composer_line"
fi
if ! ver_ge "$composer_ver" 2.4.0; then
  die 2 "Composer ${composer_ver} is older than 2.4. composer audit is required. This script will not upgrade Composer for you."
fi

if [[ ! -d "$project_dir" ]]; then
  die 2 "Not a directory: $project_dir"
fi
project_dir=$(CDPATH='' cd -- "$project_dir" && pwd)
composer_json="$project_dir/composer.json"
if [[ ! -f "$composer_json" ]]; then
  die 2 "No composer.json in ${project_dir}. This script does not create one and does not look in parent directories. For a legacy tree, create a separate toolchain project and pass --project-dir."
fi

php_reader=$(cat <<'PHP'
$raw = file_get_contents($argv[1]);
if ($raw === false) {
    fwrite(STDERR, "Could not read composer.json\n");
    exit(1);
}
$data = json_decode($raw, true);
if (!is_array($data)) {
    fwrite(STDERR, "composer.json is not a JSON object\n");
    exit(1);
}

function version_floor($constraint) {
    $constraint = trim($constraint);
    if ($constraint === "") {
        return "";
    }
    $branches = preg_split('/\s*\|\|\s*/', $constraint);
    $best = null;
    foreach ($branches as $branch) {
        $branch = trim($branch);
        if ($branch === "" || $branch === "*") {
            continue;
        }
        $found = null;
        if (preg_match('/(?:>=|\^|~|=)\s*([0-9]+)(?:\.([0-9]+))?(?:\.([0-9]+))?/', $branch, $m)) {
            $found = array((int) $m[1], isset($m[2]) ? (int) $m[2] : 0, isset($m[3]) ? (int) $m[3] : 0);
        } elseif (preg_match('/^\s*([0-9]+)(?:\.([0-9]+))?(?:\.([0-9]+))?/', $branch, $m)) {
            $found = array((int) $m[1], isset($m[2]) ? (int) $m[2] : 0, isset($m[3]) ? (int) $m[3] : 0);
        }
        if ($found === null) {
            continue;
        }
        if ($best === null || $found[0] < $best[0] || ($found[0] === $best[0] && ($found[1] < $best[1] || ($found[1] === $best[1] && $found[2] < $best[2])))) {
            $best = $found;
        }
    }
    if ($best === null) {
        return "";
    }
    return $best[0] . "." . $best[1] . "." . $best[2];
}

$platform = "";
if (isset($data["config"]["platform"]["php"])) {
    $platform = (string) $data["config"]["platform"]["php"];
}
$requirePhp = "";
if (isset($data["require"]["php"])) {
    $requirePhp = (string) $data["require"]["php"];
}
echo "PLATFORM\t" . str_replace(array("\t", "\n", "\r"), " ", $platform) . "\n";
echo "PLATFORM_FLOOR\t" . version_floor($platform) . "\n";
echo "REQUIRE_PHP\t" . str_replace(array("\t", "\n", "\r"), " ", $requirePhp) . "\n";
echo "REQUIRE_FLOOR\t" . version_floor($requirePhp) . "\n";

$sections = array("DEV" => "require-dev", "PROD" => "require");
foreach ($sections as $label => $key) {
    if (!isset($data[$key]) || !is_array($data[$key])) {
        continue;
    }
    foreach ($data[$key] as $name => $constraint) {
        if (!is_string($name)) {
            continue;
        }
        $shown = is_string($constraint) ? $constraint : json_encode($constraint);
        $shown = str_replace(array("\t", "\n", "\r"), " ", (string) $shown);
        echo $label . "\t" . $name . "\t" . $shown . "\n";
    }
}
PHP
)

meta=$(php -r "$php_reader" "$composer_json") || die 2 "Could not read ${composer_json}"

platform_raw=""
platform_floor=""
require_php_raw=""
require_floor=""
dev_rows=""
prod_rows=""
while IFS=$'\t' read -r kind field value; do
  [[ -z "${kind:-}" ]] && continue
  case "$kind" in
    PLATFORM) platform_raw=$field ;;
    PLATFORM_FLOOR) platform_floor=$field ;;
    REQUIRE_PHP) require_php_raw=$field ;;
    REQUIRE_FLOOR) require_floor=$field ;;
    DEV) dev_rows="${dev_rows}${field}"$'\t'"${value}"$'\n' ;;
    PROD) prod_rows="${prod_rows}${field}"$'\t'"${value}"$'\n' ;;
    *) ;;
  esac
done <<EOF
$meta
EOF

if [[ -n "$platform_floor" ]]; then
  platform="$platform_floor"
  platform_source="config.platform.php (${platform_raw})"
else
  platform="$runtime_php"
  platform_source="php on PATH (config.platform.php is not set)"
fi

lookup_section() {
  local rows="$1" pkg="$2" name constraint want
  want=$(lower "$pkg")
  while IFS=$'\t' read -r name constraint; do
    [[ -z "$name" ]] && continue
    if [[ "$(lower "$name")" == "$want" ]]; then
      printf '%s' "$constraint"
      return 0
    fi
  done <<EOF
$rows
EOF
  return 1
}

printf 'mode: %s\n' "$mode"
printf 'project: %s\n' "$project_dir"
printf 'runtime_php: %s\n' "$runtime_php"
printf 'composer: %s\n' "$composer_ver"
printf 'composer_platform: %s from %s\n' "$platform" "$platform_source"
if [[ -n "$require_php_raw" ]]; then
  printf 'require_php: %s (floor %s)\n' "$require_php_raw" "${require_floor:-unknown}"
else
  printf 'require_php: not set\n'
fi
printf 'scope: require-dev only. No global install, no production deploy, no edits to require or config.platform.php.\n'
assert_lockfile
assert_supply_chain

if ! ver_ge "$platform" 7.2.0; then
  warn "Composer platform PHP is ${platform}. Rector, PHPStan, Psalm, Deptrac, and current PHPUnit do not run there."
  warn "Do not use --ignore-platform-reqs and do not raise config.platform.php to force the install. That pin is the application runtime."
  warn "Run those tools from a separate Composer project on a newer PHP and point them at this tree. This script does not download a PHAR, run curl or wget, or pull an image."
  warn "Tests that claim behavior on PHP ${platform} still have to run on PHP ${platform}. A PHPUnit result from the newer PHP is not that proof."
  if ver_ge "$platform" 5.4.0; then
    warn "PHP_CodeSniffer 3 and PHPCompatibility 9 can still be installed on this platform."
  else
    warn "PHP_CodeSniffer 3 needs PHP >= 5.4, so this platform gets no packages from this script."
  fi
elif [[ -n "$require_floor" ]] && ! ver_ge "$require_floor" 7.2.0; then
  warn "require.php allows PHP ${require_floor}, while dev tools run on composer platform PHP ${platform}."
  warn "Static analysis on ${platform} does not show that the application runs there. Keep a test job on the older runtime."
fi

if [[ "$phpcs_implied" -eq 1 ]]; then
  printf 'note: PHPCompatibility 9 requires PHP_CodeSniffer ^3, so phpcs is included.\n'
fi

if [[ ! -f "$licenses_file" ]]; then
  warn "License table not found at ${licenses_file}"
fi

spec_lines=""
added=0
refused=0
user_refused=0
user_kept=0

# PHP_CodeSniffer pulled in for PHPCompatibility is not a tool the user named.
# It must not hide a refusal of the tool they did name.
mark_kept() {
  if [[ "$1" == "selected" ]]; then
    user_kept=$((user_kept + 1))
  fi
}
mark_refused() {
  refused=$((refused + 1))
  if [[ "$1" == "selected" ]]; then
    user_refused=$((user_refused + 1))
  fi
}

while IFS= read -r tool; do
  [[ -z "$tool" ]] && continue
  role="selected"
  if [[ "$tool" == "phpcs" && "$phpcs_implied" -eq 1 ]]; then
    role="implied"
  fi
  pkg=$(package_for "$tool") || die 1 "Unknown tool: $tool"
  spdx=$(license_of "$pkg")
  printf 'license: %s %s\n' "$pkg" "$spdx"
  printf '  see: %s\n' "$licenses_file"
  choose_constraint "$tool"

  if prod_constraint=$(lookup_section "$prod_rows" "$pkg"); then
    printf 'skip: %s — already in require (%s). Non-dev dependencies are not modified.\n' "$pkg" "$prod_constraint"
    mark_kept "$role"
    continue
  fi
  if dev_constraint=$(lookup_section "$dev_rows" "$pkg"); then
    printf 'skip: %s — already in require-dev (%s). Existing constraint left as it is.\n' "$pkg" "$dev_constraint"
    mark_kept "$role"
    continue
  fi
  if [[ -z "$CONSTRAINT" ]]; then
    printf 'skip: %s — %s\n' "$pkg" "$REASON"
    mark_refused "$role"
    continue
  fi
  if [[ -n "$NOTE" ]]; then
    warn "$NOTE"
  fi
  # PHPCompatibility 9 does not run on PHP_CodeSniffer ^4 or >=4. Do not downgrade that pin.
  if [[ "$tool" == "phpcompatibility" ]]; then
    if existing_phpcs=$(lookup_section "$dev_rows" "squizlabs/php_codesniffer"); then
      case "$existing_phpcs" in
        *'^4'*|*'~4'*|*'>=4'*|*' 4.'*|4.*)
          printf 'skip: %s — require-dev already pins PHP_CodeSniffer at (%s). PHPCompatibility 9 does not run on ^4 or >=4 (also ~4 or a bare 4.*). This script will not change that pin.\n' "$pkg" "$existing_phpcs"
          mark_refused "$role"
          continue
          ;;
      esac
    fi
  fi
  spec_is_allowed "$CONSTRAINT"
  printf 'add: %s\n' "$CONSTRAINT"
  spec_lines="${spec_lines}${CONSTRAINT}"$'\n'
  added=$((added + 1))
done <<EOF
$tool_lines
EOF

if [[ "$added" -eq 0 ]]; then
  printf 'command: none\n'
  if [[ "$user_refused" -gt 0 && "$user_kept" -eq 0 ]]; then
    printf 'result: nothing to install. Every selected tool was refused.\n'
    exit 4
  fi
  if [[ "$refused" -gt 0 ]]; then
    printf 'result: nothing to install. Some selected tools are already in composer.json. Others were refused.\n'
    exit 0
  fi
  printf 'result: nothing to install. Selected tools are already in composer.json.\n'
  exit 0
fi

cmd=(composer --no-interaction --no-plugins --working-dir "$project_dir" require --dev --no-scripts)
while IFS= read -r spec; do
  [[ -z "$spec" ]] && continue
  spec_is_allowed "$spec"
  cmd+=("$spec")
done <<EOF
$spec_lines
EOF

case " ${cmd[*]} " in
  *" require --dev "*) ;;
  *) die 6 "Refusing to run composer without require --dev." ;;
esac
case " ${cmd[*]} " in
  *" global "*|*" --ignore-platform-reqs "*|*" update "*|*" --repository "*|*" --repository-url "*|*"http://"*|*"curl "*|*"wget "*|*" .phar"*)
    die 6 "Refusing a composer command that is not an allowlisted dev-dependency install from packagist.org."
    ;;
esac

printf 'command:'
for arg in "${cmd[@]}"; do
  if [[ "$arg" == *[^a-zA-Z0-9_./:=@+,-]* ]]; then
    printf " '%s'" "${arg//\'/\'\\\'\'}"
  else
    printf ' %s' "$arg"
  fi
done
printf '\n'

if [[ "$mode" == "dry-run" ]]; then
  printf 'result: dry-run. composer.json was not changed. Pass --install to apply. composer audit --locked runs after a successful install.\n'
  exit 0
fi

export COMPOSER_NO_INTERACTION=1
if ! "${cmd[@]}"; then
  die 3 "composer require failed. Check git status in ${project_dir} before retrying. Non-dev requirements were not an intended target."
fi
if [[ ! -f "$project_dir/composer.lock" ]]; then
  die 6 "composer.lock is missing after require. Refusing to leave composer.json and the lock out of sync."
fi
printf 'result: require-dev updated. composer.lock was updated for those packages only. Composer scripts and plugins were not run.\n'
printf 'audit: composer audit --locked\n'
if ! composer --no-interaction --no-plugins --working-dir "$project_dir" audit --locked --no-ansi; then
  die 5 "composer audit reported advisories or could not check the lock file. require-dev was updated. Review the audit output before using the tools. This script does not ignore advisories."
fi
printf 'audit: no advisories reported for the lock file.\n'
if [[ "$refused" -gt 0 ]]; then
  warn "Some selected tools were skipped. See the skip lines above."
fi
exit 0
