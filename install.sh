#!/bin/bash
# Sets up this repo on the machine. Safe to re-run. Pass -n for a dry run.
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v go >/dev/null 2>&1; then
  echo "Go is required: brew install go" >&2
  exit 1
fi

(cd src/go/dotinstall && go build -o dotinstall .)
exec src/go/dotinstall/dotinstall "$@"
