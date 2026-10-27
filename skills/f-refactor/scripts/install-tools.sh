#!/usr/bin/env bash
# Optional installer for the f-refactor toolchain.
#
# Adds selected tools as Composer dev dependencies of one existing project.
# Dry-run unless --install. Never installs globally, never edits require,
# never edits config.platform.php, and never deploys.
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

The constraint is the newest major this script knows that declares support for
the composer platform PHP (config.platform.php when set, otherwise the php on
PATH). Composer picks the latest release inside that constraint at install time.

Exit codes:
  0  Plan printed, or install finished. Includes "already present".
  1  Bad usage (no tools, unknown tool, missing flag value)
  2  php, composer, or composer.json missing, or composer older than 2.2
  3  composer require failed
  4  Nothing was added, and every selected tool was refused
     (this PHP cannot run it, or an existing pin must not be changed)

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
    phpcompatibility/php-compatibility) printf 'LGPL-3.0' ;;
    *) printf 'unknown' ;;
  esac
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
  die 2 "composer is not on PATH. Install Composer 2.2 or newer. This script does not download or upgrade Composer."
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
if ! ver_ge "$composer_ver" 2.2.0; then
  die 2 "Composer ${composer_ver} is older than 2.2. Install Composer 2.2 or newer. This script will not upgrade Composer for you."
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

if ! ver_ge "$platform" 7.2.0; then
  warn "Composer platform PHP is ${platform}. Rector, PHPStan, Psalm, Deptrac, and current PHPUnit do not run there."
  warn "Do not use --ignore-platform-reqs and do not raise config.platform.php to force the install. That pin is the application runtime."
  warn "Run those tools from a separate modern PHP toolchain whose composer.json is not pinned to ${platform}, and point them at this source tree."
  warn "Example: a php:8.3-cli container with this repository mounted, and this script invoked with --project-dir set to a toolchain project."
  warn "Tests that claim behavior on PHP ${platform} still have to run on PHP ${platform}. A PHPUnit result from the modern toolchain is not that proof."
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
  # PHPCompatibility 9 does not run on PHP_CodeSniffer 4. Do not downgrade an existing pin.
  if [[ "$tool" == "phpcompatibility" ]]; then
    if existing_phpcs=$(lookup_section "$dev_rows" "squizlabs/php_codesniffer"); then
      case "$existing_phpcs" in
        *'^4'*|*'~4'*|*'>=4'*|*' 4.'*|4.*)
          printf 'skip: %s — require-dev already pins PHP_CodeSniffer at (%s). PHPCompatibility 9 needs ^2.3 or ^3, and this script will not change that pin.\n' "$pkg" "$existing_phpcs"
          mark_refused "$role"
          continue
          ;;
      esac
    fi
  fi
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
  cmd+=("$spec")
done <<EOF
$spec_lines
EOF

case " ${cmd[*]} " in
  *" require --dev "*) ;;
  *) die 3 "Refusing to run composer without require --dev." ;;
esac
case " ${cmd[*]} " in
  *" global "*|*" --ignore-platform-reqs "*|*" update "*) die 3 "Refusing a composer command that is not a dev-dependency install." ;;
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
  printf 'result: dry-run. composer.json was not changed. Pass --install to apply.\n'
  exit 0
fi

export COMPOSER_NO_INTERACTION=1
if ! "${cmd[@]}"; then
  die 3 "composer require failed. Check git status in ${project_dir} before retrying. Non-dev requirements were not an intended target."
fi
printf 'result: require-dev updated. Composer scripts and plugins were not run.\n'
if [[ "$refused" -gt 0 ]]; then
  warn "Some selected tools were skipped. See the skip lines above."
fi
exit 0
