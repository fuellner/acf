#!/usr/bin/env bash
# Shared checks for the isolated f-refactor toolchain.
# Source this file from build.sh, run.sh, install-host.sh, or image-install.sh.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'error: source lib.sh; do not execute it\n' >&2
  exit 1
fi

packagist_url='https://repo.packagist.org'
lib_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

die() {
  local code="$1"
  shift
  printf 'error: %s\n' "$*" >&2
  exit "$code"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

have_python() {
  command -v python3 >/dev/null 2>&1
}

# Run check.py. Returns 1 when python3 is not on PATH so the caller can use PHP.
run_check_py() {
  if ! have_python; then
    return 1
  fi
  python3 "$lib_dir/check.py" "$@"
}

assert_image_ref() {
  local ref="$1" kind="${2:-tag}"
  case "$ref" in
    -*)
      die 6 "Refusing image reference starting with '-': ${ref}"
      ;;
    *$'\n'*|*' '*|*,*)
      die 6 "Refusing image reference with whitespace, a comma, or a newline."
      ;;
  esac
  if [[ ! "$ref" =~ ^[A-Za-z0-9][A-Za-z0-9._/:@-]{0,255}$ ]]; then
    die 6 "Refusing image reference ${ref}."
  fi
  if [[ "$ref" == *"@"* && ! "$ref" =~ @sha256:[a-f0-9]{64}$ ]]; then
    die 6 "Refusing image reference ${ref}. A digest must be @sha256: and 64 hex digits."
  fi
  if [[ "$kind" == "base" && ! "$ref" =~ @sha256:[a-f0-9]{64}$ ]]; then
    die 6 "Refusing base image ${ref}. Base images must be pinned with @sha256:."
  fi
}

assert_mount_path() {
  local label="$1" path="$2"
  case "$path" in
    *$'\n'*|*,*|*:*)
      die 6 "Refusing ${label} path. A mount path cannot contain a comma, a colon, or a newline."
      ;;
  esac
}

physical_path() {
  local target="$1" cursor parent rest prefix
  if [[ -d "$target" ]]; then
    (CDPATH='' cd -P -- "$target" && pwd -P)
    return
  fi
  cursor=$target
  rest=""
  while [[ ! -d "$cursor" ]]; do
    parent=$(dirname -- "$cursor")
    if [[ "$parent" == "$cursor" ]]; then
      printf 'path was not found\n' >&2
      return 1
    fi
    rest="/$(basename -- "$cursor")${rest}"
    cursor=$parent
  done
  prefix=$(CDPATH='' cd -P -- "$cursor" && pwd -P) || return 1
  printf '%s%s' "$prefix" "$rest"
}

assert_no_overlap() {
  local left right label_left="$3" label_right="$4"
  if ! left=$(physical_path "$1" 2>&1); then
    die 2 "Could not resolve ${label_left}: ${left}"
  fi
  if ! right=$(physical_path "$2" 2>&1); then
    die 2 "Could not resolve ${label_right}: ${right}"
  fi
  left=${left%/}
  right=${right%/}
  if [[ "$left" == "$right" || "$left" == "$right"/* || "$right" == "$left"/* ]]; then
    die 6 "Refusing overlap between ${label_left} (${left}) and ${label_right} (${right})."
  fi
}

assert_tools_outside_app() {
  local tools="$1" app="${2:-}"
  if [[ -z "$app" ]]; then
    return 0
  fi
  assert_no_overlap "$tools" "$app" "tool directory" "application tree"
}

normalize_repo_url() {
  local url="$1"
  while [[ "$url" == */ ]]; do
    url="${url%/}"
  done
  printf '%s' "$url"
}

is_packagist_url() {
  [[ "$(normalize_repo_url "$1")" == "$packagist_url" ]]
}

assert_https_repo_url() {
  local url
  url=$(normalize_repo_url "$1")
  if [[ "$url" != https://* ]]; then
    die 6 "Refusing Composer source ${url}. Only an https:// URL is accepted."
  fi
  case "$url" in
    *' '*|*\\*|*@*|*'?'*|*'#'*)
      die 6 "Refusing Composer source ${url}. Use a plain https URL with no user, query, or fragment."
      ;;
  esac
  if [[ "$url" == "https://" ]]; then
    die 6 "Refusing an empty Composer source URL."
  fi
  printf '%s' "$url"
}

assert_host_env() {
  if [[ -n "${COMPOSER:-}" ]]; then
    die 6 "Refusing: COMPOSER is set. Unset it so Composer uses the tool project's composer.json."
  fi
  case "${COMPOSER_DISABLE_TLS:-}" in
    1|true|TRUE|yes|YES)
      die 6 "Refusing: COMPOSER_DISABLE_TLS is set. Composer must use HTTPS."
      ;;
  esac
  if [[ -n "${COMPOSER_CAFILE:-}" ]]; then
    die 6 "Refusing: COMPOSER_CAFILE is set. A custom CA file can redirect HTTPS trust. Unset it."
  fi
  if [[ -n "${SSL_CERT_FILE:-}" ]]; then
    die 6 "Refusing: SSL_CERT_FILE is set. A custom CA file can redirect HTTPS trust. Unset it."
  fi
  if [[ -n "${COMPOSER_AUTH:-}" ]]; then
    die 6 "Refusing: COMPOSER_AUTH is set in the environment. At image build time pass a BuildKit secret. On the host pass --composer-auth-file. The value is never printed."
  fi
  if [[ -n "${COMPOSER_HOME:-}" ]]; then
    warn "COMPOSER_HOME is set. Global Composer config from that directory is part of the host repository check."
  fi
}

refuse_missing_lock() {
  die 6 "no composer.lock in the tool project; resolving dependencies would select every package version; create the lock with --write-lock and explicit approval first"
}

# Prints the normalized URL, or exits 6 when composer.json does not describe that one source.
assert_project_source() {
  local expected="$1" file="$2" err
  if have_python; then
    if ! err=$(run_check_py source "$expected" "$file" 2>&1); then
      die 6 "Refusing tool project repositories (${err}). Exactly one https Composer source is accepted. When that source is not packagist.org, packagist.org must be disabled."
    fi
    return 0
  fi
  if ! err=$(php -r "$(cat <<'PHP'
$expected = $argv[1];
$raw = file_get_contents($argv[2]);
$data = json_decode($raw, true);
if (!is_array($data)) {
    fwrite(STDERR, "composer.json is not a JSON object\n");
    exit(1);
}
$config = (isset($data["config"]) && is_array($data["config"])) ? $data["config"] : array();
if (array_key_exists("secure-http", $config) && $config["secure-http"] !== true) {
    fwrite(STDERR, "composer.json config.secure-http is not true\n");
    exit(1);
}
if (array_key_exists("disable-tls", $config) && $config["disable-tls"] !== false) {
    fwrite(STDERR, "composer.json config.disable-tls is not false\n");
    exit(1);
}
$packagist = "https://repo.packagist.org";
if (!array_key_exists("repositories", $data) || $data["repositories"] === null) {
    if ($expected !== $packagist) {
        fwrite(STDERR, "composer.json has no repositories key, so the only source is packagist.org\n");
        exit(1);
    }
    exit(0);
}
$repos = $data["repositories"];
if (!is_array($repos)) {
    fwrite(STDERR, "composer.json repositories is not an object or list\n");
    exit(1);
}
$disabled = false;
$urls = array();
$index = 0;
$list = true;
foreach ($repos as $key => $value) {
    if ($key !== $index) {
        $list = false;
        break;
    }
    $index++;
}
$entries = array();
if ($list) {
    foreach ($repos as $value) {
        $entries[] = array("key" => null, "value" => $value);
    }
} else {
    foreach ($repos as $key => $value) {
        $entries[] = array("key" => (string) $key, "value" => $value);
    }
}
foreach ($entries as $entry) {
    $key = $entry["key"];
    $value = $entry["value"];
    if (($key === "packagist.org" || $key === "packagist") && $value === false) {
        $disabled = true;
        continue;
    }
    if (is_array($value) && array_key_exists("packagist.org", $value) && $value["packagist.org"] === false && count($value) === 1) {
        $disabled = true;
        continue;
    }
    if (is_array($value) && array_key_exists("packagist", $value) && $value["packagist"] === false && count($value) === 1) {
        $disabled = true;
        continue;
    }
    if (!is_array($value) || !isset($value["type"], $value["url"])) {
        fwrite(STDERR, "composer.json has an unexpected repository entry\n");
        exit(1);
    }
    if ($value["type"] !== "composer") {
        fwrite(STDERR, "composer.json repository type is not composer\n");
        exit(1);
    }
    $urls[] = $value["url"];
}
if (count($urls) !== 1) {
    fwrite(STDERR, "composer.json must declare exactly one Composer source\n");
    exit(1);
}
$url = $urls[0];
if ($url !== $expected) {
    fwrite(STDERR, "composer.json source does not match the configured URL\n");
    exit(1);
}
if ($expected === $packagist) {
    if ($disabled) {
        fwrite(STDERR, "composer.json disables packagist.org but the configured source is packagist.org\n");
        exit(1);
    }
    exit(0);
}
if (!$disabled) {
    fwrite(STDERR, "an internal Composer source must set packagist.org to false\n");
    exit(1);
}
exit(0);
PHP
)" "$expected" "$file" 2>&1); then
    die 6 "Refusing tool project repositories (${err}). Exactly one https Composer source is accepted. When that source is not packagist.org, packagist.org must be disabled."
  fi
}

assert_allowlist() {
  local file="$1" err
  if have_python; then
    if ! err=$(run_check_py allowlist "$file" 2>&1); then
      die 6 "Refusing tool composer.json (${err})."
    fi
    return 0
  fi
  if ! err=$(php -r "$(cat <<'PHP'
$raw = file_get_contents($argv[1]);
$data = json_decode($raw, true);
if (!is_array($data)) {
    fwrite(STDERR, "composer.json is not a JSON object\n");
    exit(1);
}
$allowed = array(
    "rector/rector" => true,
    "phpstan/phpstan" => true,
    "vimeo/psalm" => true,
    "deptrac/deptrac" => true,
    "squizlabs/php_codesniffer" => true,
    "phpcompatibility/php-compatibility" => true,
    "phpunit/phpunit" => true,
    "phalcon/ide-stubs" => true,
);
$abandoned = array(
    "phpcsstandards/php_codesniffer" => "squizlabs/php_codesniffer",
    "qossmic/deptrac" => "deptrac/deptrac",
);
$require = (isset($data["require"]) && is_array($data["require"])) ? $data["require"] : array();
if (isset($data["require-dev"]) && is_array($data["require-dev"]) && count($data["require-dev"]) > 0) {
    fwrite(STDERR, "tool composer.json must not use require-dev; direct tools belong in require\n");
    exit(1);
}
if (!isset($require["php"]) || !is_string($require["php"])) {
    fwrite(STDERR, "tool composer.json must require php >= 8.4.3\n");
    exit(1);
}
$phpOk = false;
if (preg_match('/^(?:>=8\\.4\\.(?:[3-9]|[1-9][0-9]+)|\\^8\\.4(?:\\.(?:[3-9]|[1-9][0-9]+))?)$/', trim($require["php"]))) {
    $phpOk = true;
}
if (!$phpOk) {
    fwrite(STDERR, "tool PHP constraint must be >= 8.4.3 or ^8.4. Got " . $require["php"] . "\n");
    exit(1);
}
foreach ($require as $name => $constraint) {
    if ($name === "php") {
        continue;
    }
    if (!is_string($name) || !is_string($constraint)) {
        fwrite(STDERR, "tool requirement is not a string constraint\n");
        exit(1);
    }
    if (isset($abandoned[$name])) {
        fwrite(STDERR, "refusing abandoned package " . $name . "; the official package is " . $abandoned[$name] . "\n");
        exit(1);
    }
    if (!isset($allowed[$name])) {
        fwrite(STDERR, "package " . $name . " is not on the toolchain allowlist\n");
        exit(1);
    }
    if (!preg_match('/^\^[0-9]+\.[0-9]+$/', $constraint)) {
        fwrite(STDERR, "constraint for " . $name . " must be ^MAJOR.MINOR\n");
        exit(1);
    }
}
exit(0);
PHP
)" "$file" 2>&1); then
    die 6 "Refusing tool composer.json (${err})."
  fi
}

assert_lock_urls() {
  local lock="$1" expected="$2" err
  if have_python; then
    if ! err=$(run_check_py lock "$expected" "$lock" 2>&1); then
      die 6 "Refusing tool composer.lock (${err}). Create it with --write-lock against the one configured source."
    fi
    return 0
  fi
  if ! err=$(php -r "$(cat <<'PHP'
$expected = $argv[1];
$lock = json_decode(file_get_contents($argv[2]), true);
if (!is_array($lock)) {
    fwrite(STDERR, "composer.lock is not a JSON object\n");
    exit(1);
}
$packages = array();
if (isset($lock["packages"]) && is_array($lock["packages"])) {
    $packages = array_merge($packages, $lock["packages"]);
}
if (isset($lock["packages-dev"]) && is_array($lock["packages-dev"])) {
    $packages = array_merge($packages, $lock["packages-dev"]);
}
$expectedHost = parse_url($expected, PHP_URL_HOST);
$internal = ($expected !== "https://repo.packagist.org");
if ($internal && ($expectedHost === null || $expectedHost === "")) {
    fwrite(STDERR, "configured Composer URL has no host\n");
    exit(1);
}
foreach ($packages as $pkg) {
    if (!is_array($pkg)) {
        fwrite(STDERR, "composer.lock package entry is not an object\n");
        exit(1);
    }
    foreach (array("dist", "source") as $kind) {
        if (!isset($pkg[$kind]["url"])) {
            continue;
        }
        $url = (string) $pkg[$kind]["url"];
        if (strncmp($url, "https://", 8) !== 0) {
            fwrite(STDERR, "composer.lock has a non-https " . $kind . " URL\n");
            exit(1);
        }
    }
    if ($internal) {
        if (!isset($pkg["dist"]["url"])) {
            fwrite(STDERR, "composer.lock package has no dist URL for the internal source\n");
            exit(1);
        }
        $host = parse_url((string) $pkg["dist"]["url"], PHP_URL_HOST);
        if ($host !== $expectedHost) {
            fwrite(STDERR, "composer.lock dist host is not " . $expectedHost . "\n");
            exit(1);
        }
    }
}
exit(0);
PHP
)" "$expected" "$lock" 2>&1); then
    die 6 "Refusing tool composer.lock (${err}). Create it with --write-lock against the one configured source."
  fi
}

assert_global_repos() {
  local expected="$1" json err
  command -v composer >/dev/null 2>&1 || die 2 "composer is not on PATH. The host Composer check runs only for --write-lock and the host install."
  json=$(composer --no-interaction --no-plugins config --global --json repositories 2>/dev/null) || die 6 "Could not read global Composer repositories."
  if have_python; then
    if ! err=$(printf '%s' "$json" | run_check_py global "$expected" 2>&1); then
      die 6 "Refusing global Composer repositories (${err}). Only packagist.org, or the one configured internal source, is accepted."
    fi
    return 0
  fi
  if ! err=$(F_REFACTOR_EXPECTED_REPO="$expected" printf '%s' "$json" | F_REFACTOR_EXPECTED_REPO="$expected" php -r "$(cat <<'PHP'
$expected = getenv("F_REFACTOR_EXPECTED_REPO");
$raw = stream_get_contents(STDIN);
$data = json_decode($raw, true);
if (!is_array($data)) {
    fwrite(STDERR, "global repository config is not JSON\n");
    exit(1);
}
$packagist = "https://repo.packagist.org";
$disabled = false;
$urls = array();
$index = 0;
$list = true;
foreach ($data as $key => $value) {
    if ($key !== $index) {
        $list = false;
        break;
    }
    $index++;
}
$entries = array();
if ($list) {
    foreach ($data as $value) {
        $entries[] = array("key" => null, "value" => $value);
    }
} else {
    foreach ($data as $key => $value) {
        $entries[] = array("key" => (string) $key, "value" => $value);
    }
}
foreach ($entries as $entry) {
    $key = $entry["key"];
    $value = $entry["value"];
    if (($key === "packagist.org" || $key === "packagist") && $value === false) {
        $disabled = true;
        continue;
    }
    if (!is_array($value) || !isset($value["type"], $value["url"]) || $value["type"] !== "composer") {
        fwrite(STDERR, "global Composer config has a repository that is not a composer https source\n");
        exit(1);
    }
    if ($value["url"] !== $packagist && $value["url"] !== $expected) {
        fwrite(STDERR, "global Composer config has a repository that is not the one configured source\n");
        exit(1);
    }
    foreach ($value as $opt => $unused) {
        if ($opt !== "type" && $opt !== "url") {
            fwrite(STDERR, "global repository entry has extra options\n");
            exit(1);
        }
    }
    $urls[] = $value["url"];
}
if ($expected === $packagist) {
    if ($disabled || count($urls) !== 1 || $urls[0] !== $packagist) {
        fwrite(STDERR, "global Composer config is not packagist.org only\n");
        exit(1);
    }
    exit(0);
}
$onlyInternal = ($disabled && count($urls) === 1 && $urls[0] === $expected);
$onlyDefault = (!$disabled && count($urls) === 1 && $urls[0] === $packagist);
if (!$onlyInternal && !$onlyDefault) {
    fwrite(STDERR, "global Composer config is not packagist.org only and not the one internal source\n");
    exit(1);
}
exit(0);
PHP
)" 2>&1); then
    die 6 "Refusing global Composer repositories (${err}). Only packagist.org, or the one configured internal source, is accepted."
  fi
}

prepare_tool_args() {
  local base
  TOOL_CMD=()
  if [[ $# -lt 1 ]]; then
    die 1 "Pass a tool command after --. Example: -- phpstan analyse src"
  fi
  base=$(basename -- "$1")
  shift
  case "$base" in
    rector)
      TOOL_CMD=(/opt/toolchain/vendor/bin/rector "$@")
      local dry=0 arg
      for arg in "$@"; do
        if [[ "$arg" == "--dry-run" ]]; then
          dry=1
        fi
      done
      if [[ "$dry" -eq 0 ]]; then
        TOOL_CMD+=(--dry-run)
      fi
      local cache=0
      for arg in "$@"; do
        if [[ "$arg" == "--cache-file" || "$arg" == --cache-file=* ]]; then
          cache=1
        fi
      done
      if [[ "$cache" -eq 0 ]]; then
        TOOL_CMD+=(--cache-file /tmp/rector.cache)
      fi
      ;;
    phpcbf)
      TOOL_CMD=(/opt/toolchain/vendor/bin/phpcs --report=diff --report-file=/out/phpcs.diff "$@")
      ;;
    phpstan|psalm|deptrac|phpcs|phpunit)
      TOOL_CMD=(/opt/toolchain/vendor/bin/"$base" "$@")
      ;;
    *)
      die 6 "Refusing tool ${base}. Allowed commands: rector, phpstan, psalm, deptrac, phpcs, phpcbf, phpunit."
      ;;
  esac
}

print_quoted_args() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == *[^a-zA-Z0-9_./:=@+,~-]* ]]; then
      printf " '%s'" "${arg//\'/\'\\\'\'}"
    else
      printf ' %s' "$arg"
    fi
  done
  printf '\n'
}

dockerfile_arg() {
  local name="$1" file="$2" line
  line=$(grep -E "^ARG ${name}=" "$file" | head -n 1) || die 2 "Dockerfile has no ARG ${name}"
  printf '%s' "${line#ARG "${name}"=}"
}

lock_content_hash() {
  local lock="$1"
  if have_python; then
    run_check_py hash "$lock"
    return
  fi
  # shellcheck disable=SC2016
  php -r '$d=json_decode(file_get_contents($argv[1]), true); echo is_array($d) ? (string) ($d["content-hash"] ?? "") : "";' "$lock"
}

rewrite_project_source() {
  local file="$1" expected="$2"
  if have_python; then
    run_check_py rewrite "$file" "$expected" || die 6 "Could not record the single Composer source in the tool composer.json."
    return 0
  fi
  php -r "$(cat <<'PHP'
$file = $argv[1];
$expected = $argv[2];
$data = json_decode(file_get_contents($file), true);
if (!is_array($data)) {
    fwrite(STDERR, "composer.json is not a JSON object\n");
    exit(1);
}
$packagist = "https://repo.packagist.org";
if ($expected === $packagist) {
    unset($data["repositories"]);
} else {
    $data["repositories"] = array(
        "packagist.org" => false,
        "internal" => array("type" => "composer", "url" => $expected),
    );
}
$json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
if ($json === false) {
    fwrite(STDERR, "could not encode composer.json\n");
    exit(1);
}
file_put_contents($file, $json . "\n");
PHP
)" "$file" "$expected" || die 6 "Could not record the single Composer source in the tool composer.json."
}

run_composer() {
  local auth_file="$1"
  shift
  if [[ -n "$auth_file" ]]; then
    COMPOSER_AUTH=$(cat -- "$auth_file") "$@"
  else
    "$@"
  fi
}
