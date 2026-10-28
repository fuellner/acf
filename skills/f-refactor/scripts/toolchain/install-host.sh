#!/usr/bin/env bash
# Install the toolchain into a directory outside the application, or run one tool there.
# Dry-run unless --install, --write-lock, or --run. The host PHP must be >= 8.4.3.
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

mode="dry-run"
name="default"
tools_dir=""
app_dir=""
out_dir=""
repo_url="$packagist_url"
auth_file=""
toolchain_dir="$script_dir"

usage() {
  cat <<'EOF'
Usage: install-host.sh [options] [-- <tool> [args...]]

Fallback when no container engine is available. Installs the f-refactor tools
into a directory outside the application (default:
${XDG_DATA_HOME:-$HOME/.local/share}/f-refactor-tools/<name>) and can run one
tool from there. Dry-run unless --install, --write-lock, or --run.

This script never changes the application's composer.json, composer.lock, or
vendor directory. The host PHP that runs the tools must be >= 8.4.3. An
application on PHP 5.3 stays on PHP 5.3; these tools do not run on that binary.

Rector is forced to --dry-run. phpcbf is rewritten to a diff report under --out.
There is no container sandbox in this mode: no --network none and no read-only
mount. Do not point the tool at a writable copy you are not prepared to diff.

Options:
  --help, -h                 Show this help
  --dry-run                  Print the plan (default)
  --install                  composer install in the tool directory
  --write-lock               Write composer.lock in the tool directory
  --run                      Run the tool command after --
  --name NAME                Directory name (default: default)
  --tools-dir DIR            Override the tool directory
  --toolchain-dir DIR        Source composer.json and composer.lock
  --app DIR                  Application tree. Used only as a path check and as
                             the working directory of --run. Not a Composer project target
  --out DIR                  Report directory for --run
  --composer-repo URL        The one Composer source
  --composer-auth-file PATH  Auth file for host Composer. Never printed

Exit codes match build.sh: 0 plan or success, 1 usage, 2 missing program,
3 composer or the tool failed, 5 audit failed, 6 supply-chain refusal.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --dry-run) mode="dry-run"; shift ;;
    --install) mode="install"; shift ;;
    --write-lock) mode="write-lock"; shift ;;
    --run) mode="run"; shift ;;
    --name)
      [[ $# -ge 2 ]] || die 1 "--name needs a value"
      name="$2"
      shift 2
      ;;
    --name=*) name="${1#*=}"; shift ;;
    --tools-dir)
      [[ $# -ge 2 ]] || die 1 "--tools-dir needs a directory"
      tools_dir="$2"
      shift 2
      ;;
    --tools-dir=*) tools_dir="${1#*=}"; shift ;;
    --toolchain-dir)
      [[ $# -ge 2 ]] || die 1 "--toolchain-dir needs a directory"
      toolchain_dir="$2"
      shift 2
      ;;
    --toolchain-dir=*) toolchain_dir="${1#*=}"; shift ;;
    --app)
      [[ $# -ge 2 ]] || die 1 "--app needs a directory"
      app_dir="$2"
      shift 2
      ;;
    --app=*) app_dir="${1#*=}"; shift ;;
    --out)
      [[ $# -ge 2 ]] || die 1 "--out needs a directory"
      out_dir="$2"
      shift 2
      ;;
    --out=*) out_dir="${1#*=}"; shift ;;
    --composer-repo)
      [[ $# -ge 2 ]] || die 1 "--composer-repo needs an https URL"
      repo_url="$2"
      shift 2
      ;;
    --composer-repo=*) repo_url="${1#*=}"; shift ;;
    --composer-auth-file)
      [[ $# -ge 2 ]] || die 1 "--composer-auth-file needs a file"
      auth_file="$2"
      shift 2
      ;;
    --composer-auth-file=*) auth_file="${1#*=}"; shift ;;
    --)
      shift
      break
      ;;
    *)
      die 1 "Unknown option: $1"
      ;;
  esac
done

repo_url=$(assert_https_repo_url "$repo_url")
assert_host_env
if [[ -n "$auth_file" ]]; then
  [[ -f "$auth_file" && ! -L "$auth_file" ]] || die 1 "--composer-auth-file must be a regular file"
fi
case "$name" in
  ''|.*|*/*) die 1 "--name must be a single path segment" ;;
esac
if [[ -z "$tools_dir" ]]; then
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  tools_dir="${data_home}/f-refactor-tools/${name}"
fi
if [[ ! -d "$toolchain_dir" ]]; then
  die 2 "Tool project directory not found: $toolchain_dir"
fi
toolchain_dir=$(CDPATH='' cd -- "$toolchain_dir" && pwd)
assert_tools_outside_app "$tools_dir" "$app_dir"
if [[ -n "$app_dir" && -n "$out_dir" ]]; then
  assert_no_overlap "$app_dir" "$out_dir" "application tree" "output directory"
fi

source_json="$toolchain_dir/composer.json"
source_lock="$toolchain_dir/composer.lock"
[[ -f "$source_json" ]] || die 2 "No composer.json in $toolchain_dir"

assert_global_repos "$repo_url"
assert_allowlist "$source_json"
if [[ "$mode" != "write-lock" ]]; then
  [[ -f "$source_lock" ]] || refuse_missing_lock
  assert_project_source "$repo_url" "$source_json"
  assert_lock_urls "$source_lock" "$repo_url"
fi

if is_packagist_url "$repo_url"; then
  packagist_state="enabled"
else
  packagist_state="disabled"
fi

printf 'mode: %s\n' "$mode"
printf 'tools: %s\n' "$tools_dir"
printf 'source: %s\n' "$repo_url"
printf 'packagist.org: %s\n' "$packagist_state"
printf 'host_php: >= 8.4.3 required to execute the tools. config.platform.php in the tool project is 8.4.3.\n'
printf 'scope: tool directory only. Application composer.json, composer.lock, and vendor are not modified.\n'
if [[ -n "$app_dir" ]]; then
  printf 'app: %s\n' "$app_dir"
fi

if [[ "$mode" == "dry-run" && $# -eq 0 ]]; then
  printf 'result: dry-run. No files were copied and composer was not run. Pass --install or --write-lock.\n'
  exit 0
fi

if [[ "$mode" == "write-lock" ]]; then
  mkdir -p -- "$tools_dir"
  assert_tools_outside_app "$tools_dir" "$app_dir"
  if [[ ! -f "$tools_dir/composer.json" ]]; then
    cp -- "$source_json" "$tools_dir/composer.json"
  fi
  if ! is_packagist_url "$repo_url"; then
    rewrite_project_source "$tools_dir/composer.json" "$repo_url"
  fi
  assert_allowlist "$tools_dir/composer.json"
  printf 'command: composer update --no-install --no-plugins --no-scripts --working-dir %s\n' "$tools_dir"
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$tools_dir" update --no-install --no-scripts --no-progress --prefer-dist; then
    die 3 "composer update failed in the tool directory."
  fi
  [[ -f "$tools_dir/composer.lock" ]] || refuse_missing_lock
  assert_project_source "$repo_url" "$tools_dir/composer.json"
  assert_lock_urls "$tools_dir/composer.lock" "$repo_url"
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$tools_dir" audit --locked --no-ansi; then
    die 5 "composer audit reported advisories for the tool lock. The lock was written. This script does not ignore advisories."
  fi
  printf 'result: tool lock written in %s.\n' "$tools_dir"
  exit 0
fi

if [[ "$mode" == "install" ]]; then
  if [[ ! -f "$source_lock" ]]; then
    refuse_missing_lock
  fi
  assert_project_source "$repo_url" "$source_json"
  assert_lock_urls "$source_lock" "$repo_url"
  mkdir -p -- "$tools_dir"
  assert_tools_outside_app "$tools_dir" "$app_dir"
  cp -- "$source_json" "$tools_dir/composer.json"
  cp -- "$source_lock" "$tools_dir/composer.lock"
  printf 'command: composer install --no-dev --no-plugins --no-scripts --working-dir %s\n' "$tools_dir"
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$tools_dir" install --no-dev --no-scripts --no-progress --prefer-dist; then
    die 3 "composer install failed in the tool directory."
  fi
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$tools_dir" audit --locked --no-ansi; then
    die 5 "composer audit reported advisories for the tool lock. vendor was installed. This script does not ignore advisories."
  fi
  printf 'result: tools installed in %s/vendor/bin. Host PHP must be >= 8.4.3.\n' "$tools_dir"
  exit 0
fi

if [[ "$mode" == "run" || $# -gt 0 ]]; then
  [[ -n "$app_dir" && -d "$app_dir" ]] || die 1 "--run requires --app to be an existing directory"
  [[ -n "$out_dir" ]] || die 1 "--run requires --out"
  prepare_tool_args "$@"
  host_cmd=()
  for arg in "${TOOL_CMD[@]}"; do
    case "$arg" in
      /opt/toolchain/vendor/bin/*)
        host_cmd+=("${tools_dir}/vendor/bin/$(basename -- "$arg")")
        ;;
      /out/*)
        host_cmd+=("${out_dir}/$(basename -- "$arg")")
        ;;
      *)
        host_cmd+=("$arg")
        ;;
    esac
  done
  printf 'command:'
  print_quoted_args "${host_cmd[@]}"
  if [[ "$mode" != "run" ]]; then
    printf 'result: dry-run. The tool was not executed.\n'
    exit 0
  fi
  bin="${host_cmd[0]}"
  [[ -x "$bin" ]] || die 2 "Tool binary not found: ${bin}. Pass --install first."
  app_dir=$(physical_path "$app_dir") || die 2 "Could not resolve --app"
  assert_no_overlap "$app_dir" "$out_dir" "application tree" "output directory"
  mkdir -p -- "$out_dir"
  log="${out_dir}/$(basename -- "$1").log"
  set +e
  (cd -- "$app_dir" && "${host_cmd[@]}") >"$log" 2>&1
  status=$?
  set -e
  if (( status != 0 )); then
    printf 'result: tool exited %s\n' "$status" >&2
    exit "$status"
  fi
  printf 'result: tool finished. The application Composer files were not modified by this script.\n'
  exit 0
fi

printf 'result: dry-run. No files were copied and composer was not run.\n'
exit 0
