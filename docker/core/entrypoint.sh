#!/usr/bin/env bash
set -euo pipefail

rm -rf "${HOME}/.cache" "${HOME}/.local"

exec "$@"
