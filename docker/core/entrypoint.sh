#!/usr/bin/env bash
set -euo pipefail
 
bin/rails db:create

exec "$@"
