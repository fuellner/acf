#!/usr/bin/env bash
# Build the isolated f-refactor tool image, or write the tool project's lock.
# Dry-run unless --build or --write-lock. Does not modify an application project.
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$script_dir/lib.sh"

mode="dry-run"
want_lock=0
explicit_dry=0
explicit_build=0
toolchain_dir_set=0
toolchain_dir="$script_dir"
repo_url="$packagist_url"
php_image=""
composer_image=""
image_tag="f-refactor-toolchain:local"
runtime=""
auth_file=""

usage() {
  cat <<'EOF'
Usage: build.sh [options]

Print the image build for the isolated f-refactor toolchain. The default is a
dry-run: nothing is built and no lock is written. Pass --build to run the
container engine. Pass --write-lock to create or refresh composer.lock in the
tool project. That step resolves every tool dependency and needs explicit approval.

The application composer.json, composer.lock, and vendor directory are not
targets of this script.

Options:
  --help, -h                 Show this help
  --dry-run                  Print the plan only (default). Combined with --write-lock,
                             prints where the lock would be written and changes nothing
  --build                    Build the image. Needs python3 and docker or podman.
                             PHP and Composer run inside the image, not on the host
  --write-lock               Write the tool lock outside this skill checkout, then audit it.
                             Needs host PHP, Composer, and python3. Never edits scripts/toolchain
  --toolchain-dir DIR        Tool project for --write-lock. Must be outside this skill.
                             Default: $XDG_DATA_HOME/f-refactor-tools/lock-work
  --composer-repo URL        The one Composer source. Default https://repo.packagist.org.
                             Any other https URL disables packagist.org
  --php-image REF            Base image. Default is the digest pin in the Dockerfile
  --composer-image REF       Image that provides the composer binary. Default is the digest pin
  --tag NAME                 Image tag (default: f-refactor-toolchain:local)
  --runtime docker|podman    Container engine. Default: docker, else podman
  --composer-auth-file PATH  BuildKit secret for --build or --write-lock. Never printed.
                             Do not set COMPOSER_AUTH in the environment

Exit codes:
  0  Plan printed, image built, or lock written and audit clean
  1  Bad usage
  2  Required program or file missing, or the container engine is missing for --build
  3  composer or the image build failed
  5  composer audit reported advisories
  6  Supply-chain refusal (source, lock, TLS, auth, allowlist)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --dry-run) explicit_dry=1; shift ;;
    --build) explicit_build=1; shift ;;
    --write-lock) want_lock=1; shift ;;
    --toolchain-dir)
      [[ $# -ge 2 ]] || die 1 "--toolchain-dir needs a directory"
      toolchain_dir="$2"
      toolchain_dir_set=1
      shift 2
      ;;
    --toolchain-dir=*)
      toolchain_dir="${1#*=}"
      [[ -n "$toolchain_dir" ]] || die 1 "--toolchain-dir needs a directory"
      toolchain_dir_set=1
      shift
      ;;
    --composer-repo)
      [[ $# -ge 2 ]] || die 1 "--composer-repo needs an https URL"
      repo_url="$2"
      shift 2
      ;;
    --composer-repo=*)
      repo_url="${1#*=}"
      shift
      ;;
    --php-image)
      [[ $# -ge 2 ]] || die 1 "--php-image needs an image reference"
      php_image="$2"
      shift 2
      ;;
    --php-image=*) php_image="${1#*=}"; shift ;;
    --composer-image)
      [[ $# -ge 2 ]] || die 1 "--composer-image needs an image reference"
      composer_image="$2"
      shift 2
      ;;
    --composer-image=*) composer_image="${1#*=}"; shift ;;
    --tag)
      [[ $# -ge 2 ]] || die 1 "--tag needs an image tag"
      image_tag="$2"
      shift 2
      ;;
    --tag=*) image_tag="${1#*=}"; shift ;;
    --runtime)
      [[ $# -ge 2 ]] || die 1 "--runtime needs docker or podman"
      runtime="$2"
      shift 2
      ;;
    --runtime=*) runtime="${1#*=}"; shift ;;
    --composer-auth-file)
      [[ $# -ge 2 ]] || die 1 "--composer-auth-file needs a file"
      auth_file="$2"
      shift 2
      ;;
    --composer-auth-file=*) auth_file="${1#*=}"; shift ;;
    *)
      die 1 "Unknown option: $1"
      ;;
  esac
done

if [[ "$explicit_build" -eq 1 && "$want_lock" -eq 1 ]]; then
  die 1 "Pass only one of --build or --write-lock."
fi
if [[ "$explicit_dry" -eq 1 || ( "$explicit_build" -eq 0 && "$want_lock" -eq 0 ) ]]; then
  mode="dry-run"
elif [[ "$want_lock" -eq 1 ]]; then
  mode="write-lock"
else
  mode="build"
fi

repo_url=$(assert_https_repo_url "$repo_url")
if [[ "$mode" == "write-lock" ]]; then
  assert_host_env
fi
if [[ -n "$auth_file" ]]; then
  [[ -f "$auth_file" && ! -L "$auth_file" ]] || die 1 "--composer-auth-file must be a regular file"
fi
if [[ -d "$toolchain_dir" ]]; then
  toolchain_dir=$(CDPATH='' cd -- "$toolchain_dir" && pwd)
elif [[ "$want_lock" -eq 0 ]]; then
  die 2 "Tool project directory not found: $toolchain_dir"
fi
dockerfile="$script_dir/Dockerfile"
[[ -f "$dockerfile" ]] || die 2 "Dockerfile not found: $dockerfile"
if [[ "$want_lock" -eq 0 ]]; then
  json="$toolchain_dir/composer.json"
  lock="$toolchain_dir/composer.lock"
  [[ -f "$json" ]] || die 2 "No composer.json in the tool project: $json"
else
  json="$script_dir/composer.json"
  lock="$script_dir/composer.lock"
  [[ -f "$json" ]] || die 2 "No composer.json in the tool project: $json"
fi

if [[ -z "$php_image" ]]; then
  php_image=$(dockerfile_arg PHP_IMAGE "$dockerfile")
fi
if [[ -z "$composer_image" ]]; then
  composer_image=$(dockerfile_arg COMPOSER_IMAGE "$dockerfile")
fi
assert_image_ref "$php_image" base
assert_image_ref "$composer_image" base
assert_image_ref "$image_tag" tag

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

script_phys=$(CDPATH='' cd -P -- "$script_dir" && pwd -P)
if [[ "$want_lock" -eq 1 && "$toolchain_dir_set" -eq 1 ]]; then
  if [[ -d "$toolchain_dir" ]]; then
    toolchain_phys=$(CDPATH='' cd -P -- "$toolchain_dir" && pwd -P)
  else
    toolchain_phys=$(physical_path "$toolchain_dir") || die 2 "Could not resolve --toolchain-dir."
  fi
  if [[ "$toolchain_phys" == "$script_phys" || "$toolchain_phys" == "$script_phys"/* ]]; then
    die 6 "Refusing to rewrite the skill checkout at ${toolchain_phys}. Omit --toolchain-dir to use the data directory, or pass a directory outside this skill."
  fi
fi
if [[ "$want_lock" -eq 1 && "$toolchain_dir_set" -eq 0 ]]; then
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  toolchain_dir="${data_home}/f-refactor-tools/lock-work"
fi
if [[ "$mode" == "dry-run" && "$want_lock" -eq 1 ]]; then
  printf 'mode: dry-run\n'
  printf 'lock_dir: %s\n' "$toolchain_dir"
  printf 'source: %s\n' "$repo_url"
  printf 'skill_checkout: unchanged\n'
  printf 'result: dry-run. --write-lock would copy the tool project to that directory and run composer update there. scripts/toolchain is not modified.\n'
  exit 0
fi
if [[ "$mode" == "write-lock" ]]; then
  if [[ -d "$toolchain_dir" ]]; then
    toolchain_phys=$(CDPATH='' cd -P -- "$toolchain_dir" && pwd -P)
  else
    toolchain_phys=$(physical_path "$toolchain_dir") || die 2 "Could not resolve --toolchain-dir."
  fi
  if [[ "$toolchain_phys" == "$script_phys" || "$toolchain_phys" == "$script_phys"/* ]]; then
    die 6 "Refusing to rewrite the skill checkout at ${toolchain_phys}. Omit --toolchain-dir to use the data directory, or pass a directory outside this skill."
  fi
  assert_global_repos "$repo_url"
else
  [[ -f "$lock" ]] || refuse_missing_lock
  assert_allowlist "$json"
  assert_project_source "$repo_url" "$json"
  assert_lock_urls "$lock" "$repo_url"
fi

if is_packagist_url "$repo_url"; then
  packagist_state="enabled"
else
  packagist_state="disabled"
fi

printf 'mode: %s\n' "$mode"
printf 'toolchain: %s\n' "$toolchain_dir"
printf 'source: %s\n' "$repo_url"
printf 'packagist.org: %s\n' "$packagist_state"
printf 'php_image: %s\n' "$php_image"
printf 'composer_image: %s\n' "$composer_image"
printf 'tag: %s\n' "$image_tag"
printf 'runtime: %s\n' "$runtime"
if [[ -f "$lock" ]]; then
  hash=$(lock_content_hash "$lock")
  if [[ -n "$hash" ]]; then
    printf 'suggested-tag: %s\n' "$hash"
  fi
else
  printf 'lock: missing\n'
fi

cmd=("$runtime" build --file "$dockerfile" --build-arg "PHP_IMAGE=${php_image}" --build-arg "COMPOSER_IMAGE=${composer_image}" --build-arg "COMPOSER_REPO=${repo_url}" --tag "$image_tag")
if [[ -n "$auth_file" ]]; then
  cmd+=(--secret "id=composer_auth,src=${auth_file}")
  printf 'secret: BuildKit id=composer_auth (contents not shown)\n'
fi
cmd+=("$toolchain_dir")

if [[ "$mode" == "dry-run" ]]; then
  printf 'command:'
  print_quoted_args "${cmd[@]}"
  printf 'result: dry-run. No image was built and the tool lock was not written. Pass --build or --write-lock.\n'
  exit 0
fi

if [[ "$mode" == "write-lock" ]]; then
  if ! command -v composer >/dev/null 2>&1; then
    die 2 "composer is not on PATH. --write-lock uses the host Composer and does not download it."
  fi
  mkdir -p -- "$toolchain_dir"
  toolchain_phys=$(CDPATH='' cd -P -- "$toolchain_dir" && pwd -P)
  if [[ "$toolchain_phys" == "$script_phys" || "$toolchain_phys" == "$script_phys"/* ]]; then
    die 6 "Refusing to rewrite the skill checkout at ${toolchain_phys}."
  fi
  if [[ ! -f "$toolchain_dir/composer.json" ]]; then
    cp -- "$script_dir/composer.json" "$toolchain_dir/composer.json"
  fi
  if [[ ! -f "$toolchain_dir/composer.lock" && -f "$script_dir/composer.lock" ]]; then
    cp -- "$script_dir/composer.lock" "$toolchain_dir/composer.lock"
  fi
  json="$toolchain_dir/composer.json"
  lock="$toolchain_dir/composer.lock"
  if ! is_packagist_url "$repo_url"; then
    rewrite_project_source "$json" "$repo_url"
    printf 'recorded source in %s with packagist.org disabled\n' "$json"
  else
    assert_project_source "$repo_url" "$json"
  fi
  printf 'command: composer update --no-install --no-plugins --no-scripts --no-interaction --prefer-dist\n'
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$toolchain_dir" update --no-install --no-scripts --no-progress --prefer-dist; then
    die 3 "composer update failed while writing the tool lock. The application project was not a target."
  fi
  [[ -f "$lock" ]] || refuse_missing_lock
  assert_project_source "$repo_url" "$json"
  assert_lock_urls "$lock" "$repo_url"
  printf 'audit: composer audit --locked\n'
  if ! run_composer "$auth_file" composer --no-interaction --no-plugins --working-dir "$toolchain_dir" audit --locked --no-ansi; then
    die 5 "composer audit reported advisories for the tool lock. The lock was written. Review it before --build. This script does not ignore advisories."
  fi
  printf 'result: tool lock written. Application composer files were not changed by this script.\n'
  exit 0
fi

if ! command -v "$runtime" >/dev/null 2>&1; then
  die 2 "${runtime} is not on PATH. Install Docker or Podman, or pass --runtime."
fi
printf 'command:'
print_quoted_args "${cmd[@]}"
if ! "${cmd[@]}"; then
  die 3 "${runtime} build failed. The application project was not a target."
fi
printf 'result: image %s built from %s. Push it yourself if an internal registry should host it. This script does not push.\n' "$image_tag" "$repo_url"
exit 0
