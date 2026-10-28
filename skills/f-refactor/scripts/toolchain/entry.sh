#!/usr/bin/env bash
# Container entry. Rewrites Rector and phpcbf so they cannot edit /app.
set -euo pipefail
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$script_dir/lib.sh"
if [[ $# -lt 1 ]]; then
  printf 'usage: rector|phpstan|psalm|deptrac|phpcs|phpcbf|phpunit [args]\n' >&2
  exit 1
fi
prepare_tool_args "$@"
exec "${TOOL_CMD[@]}"
