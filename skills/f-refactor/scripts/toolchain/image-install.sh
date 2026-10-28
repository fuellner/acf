#!/usr/bin/env bash
# Build-time install inside the tool image. One Composer source, then the lock.
# COMPOSER_AUTH is read from a BuildKit secret file only, never printed.
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

if [[ -n "${COMPOSER_AUTH:-}" ]]; then
  die 6 "Refusing COMPOSER_AUTH from the environment. Mount it as the BuildKit secret composer_auth."
fi
if [[ -n "${COMPOSER_CAFILE:-}" || -n "${SSL_CERT_FILE:-}" ]]; then
  die 6 "Refusing a custom CA file during the image build."
fi
case "${COMPOSER_DISABLE_TLS:-}" in
  1|true|TRUE|yes|YES)
    die 6 "Refusing COMPOSER_DISABLE_TLS during the image build."
    ;;
esac

repo="${COMPOSER_REPO:-$packagist_url}"
repo=$(assert_https_repo_url "$repo")
json="$script_dir/composer.json"
lock="$script_dir/composer.lock"
if [[ ! -f "$lock" ]]; then
  refuse_missing_lock
fi
assert_project_source "$repo" "$json"
assert_allowlist "$json"
assert_lock_urls "$lock" "$repo"

if [[ -f /run/secrets/composer_auth ]]; then
  COMPOSER_AUTH=$(cat -- /run/secrets/composer_auth)
  export COMPOSER_AUTH
fi

effective=$(composer --no-interaction --no-plugins --working-dir "$script_dir" config --json repositories 2>/dev/null) || die 6 "Could not read Composer repositories inside the image."
if ! err=$(printf '%s' "$effective" | php -r "$(cat <<'PHP'
$expected = $argv[1];
$data = json_decode(stream_get_contents(STDIN), true);
if (!is_array($data)) {
    fwrite(STDERR, "repository config is not JSON\n");
    exit(1);
}
$urls = array();
$disabled = false;
foreach ($data as $key => $value) {
    if (($key === "packagist.org" || $key === "packagist") && $value === false) {
        $disabled = true;
        continue;
    }
    if (!is_array($value) || !isset($value["type"], $value["url"]) || $value["type"] !== "composer") {
        fwrite(STDERR, "effective repositories are not one composer source\n");
        exit(1);
    }
    $urls[] = $value["url"];
}
if (count($urls) !== 1 || $urls[0] !== $expected) {
    fwrite(STDERR, "effective Composer source is not the configured URL\n");
    exit(1);
}
if ($expected !== "https://repo.packagist.org" && !$disabled) {
    fwrite(STDERR, "packagist.org is still enabled\n");
    exit(1);
}
exit(0);
PHP
)" "$repo" 2>&1); then
  die 6 "Refusing effective Composer repositories (${err})."
fi

if ! composer --no-interaction --no-plugins --working-dir "$script_dir" install --no-dev --no-scripts --no-progress --prefer-dist; then
  die 3 "composer install failed inside the tool image. The application project was not a target."
fi
if ! composer --no-interaction --no-plugins --working-dir "$script_dir" audit --locked --no-ansi; then
  die 5 "composer audit reported advisories for the tool lock. The image build stops. This script does not ignore advisories."
fi
unset COMPOSER_AUTH || true
rm -rf "${COMPOSER_HOME:-/tmp/composer}"
