#!/usr/bin/env bash
# Run one toolchain command in a container. Dry-run unless --run.
# The application tree is mounted read-only. Network is disabled.
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

mode="dry-run"
app_dir=""
out_dir=""
image_tag="f-refactor-toolchain:local"
runtime=""

usage() {
  cat <<'EOF'
Usage: run.sh [options] -- <tool> [args...]

Print the container command that runs one f-refactor tool against an
application tree. The default is a dry-run. Pass --run to execute it.

The mount of the application is read-only. Rector is forced to --dry-run.
phpcbf is rewritten to phpcs --report=diff and writes /out/phpcs.diff.
Nothing is applied to the application. The container has no network, drops
all capabilities, and uses a read-only root filesystem with tmpfs on /tmp.

Options:
  --help, -h                 Show this help
  --dry-run                  Print the container command (default)
  --run                      Execute it
  --app DIR                  Application tree to mount at /app
  --out DIR                  Writable report directory, mounted at /out
  --image NAME               Image tag (default: f-refactor-toolchain:local)
  --runtime docker|podman    Container engine. Default: docker, else podman

Exit codes:
  0  Plan printed, or the tool exited 0
  1  Bad usage
  2  Directory or container engine missing
  3  The container engine failed before the tool ran
  6  Tool command is not allowed
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --dry-run) mode="dry-run"; shift ;;
    --run) mode="run"; shift ;;
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
    --image)
      [[ $# -ge 2 ]] || die 1 "--image needs a name"
      image_tag="$2"
      shift 2
      ;;
    --image=*) image_tag="${1#*=}"; shift ;;
    --runtime)
      [[ $# -ge 2 ]] || die 1 "--runtime needs docker or podman"
      runtime="$2"
      shift 2
      ;;
    --runtime=*) runtime="${1#*=}"; shift ;;
    --)
      shift
      break
      ;;
    *)
      die 1 "Unknown option: $1. Put the tool command after --."
      ;;
  esac
done

[[ -n "$app_dir" ]] || die 1 "--app is required"
[[ -n "$out_dir" ]] || die 1 "--out is required"
[[ -d "$app_dir" ]] || die 2 "Application directory not found: $app_dir"
app_dir=$(CDPATH='' cd -- "$app_dir" && pwd)
if [[ -d "$out_dir" ]]; then
  out_dir=$(CDPATH='' cd -- "$out_dir" && pwd)
else
  parent=$(dirname -- "$out_dir")
  [[ -d "$parent" ]] || die 2 "Parent of the output directory was not found: $parent"
  base=$(basename -- "$out_dir")
  out_dir=$(CDPATH='' cd -- "$parent" && pwd)/"$base"
fi

if [[ -z "$runtime" ]]; then
  if command -v docker >/dev/null 2>&1; then
    runtime="docker"
  elif command -v podman >/dev/null 2>&1; then
    runtime="podman"
  else
    runtime="docker"
  fi
fi
case "$runtime" in
  docker|podman) ;;
  *) die 1 "--runtime must be docker or podman" ;;
esac

prepare_tool_args "$@"
if [[ "$(id -u)" -eq 0 ]]; then
  run_user="10001:10001"
else
  run_user="$(id -u):$(id -g)"
fi

tool_name=$(basename -- "$1")
case "$tool_name" in
  phpcbf) report_name="phpcs" ;;
  *) report_name="$tool_name" ;;
esac

cmd=(
  "$runtime" run
  --rm
  --network none
  --read-only
  --cap-drop ALL
  --security-opt no-new-privileges
  --tmpfs "/tmp:rw,nosuid,nodev,size=256m"
  --tmpfs "/var/tmp:rw,nosuid,nodev,size=64m"
  --user "$run_user"
  --env HOME=/tmp
  --env TMPDIR=/tmp
  --volume "${app_dir}:/app:ro"
  --volume "${out_dir}:/out:rw"
  --workdir /app
  "$image_tag"
)
cmd+=("${TOOL_CMD[@]}")

printf 'mode: %s\n' "$mode"
printf 'app: %s\n' "$app_dir"
printf 'out: %s\n' "$out_dir"
printf 'report: %s/%s.log\n' "$out_dir" "$report_name"
printf 'network: none\n'
printf 'app_mount: read-only\n'
printf 'command:'
print_quoted_args "${cmd[@]}"

if [[ "$mode" == "dry-run" ]]; then
  printf 'result: dry-run. The container was not started. Pass --run to execute. Reports stay in the output directory. Diffs are not applied to the application.\n'
  exit 0
fi

if ! command -v "$runtime" >/dev/null 2>&1; then
  die 2 "${runtime} is not on PATH."
fi
mkdir -p -- "$out_dir"
if ! "${cmd[@]}" >"${out_dir}/${report_name}.log" 2>&1; then
  status=$?
  printf 'result: tool exited %s. Log: %s/%s.log\n' "$status" "$out_dir" "$report_name" >&2
  exit "$status"
fi
printf 'result: tool finished. Log: %s/%s.log. The application tree was mounted read-only.\n' "$out_dir" "$report_name"
exit 0
