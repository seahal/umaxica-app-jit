#!/usr/bin/env bash
set -euo pipefail

# Working dir should be /main from Dockerfile, but ensure
cd "${APP_ROOT:-/main}"

if [[ "${CI:-}" == "true" ]]; then
  echo "=== Running in CI mode ==="
  bundle install --jobs "${BUNDLE_JOBS:-4}"
  bun install --frozen-lockfile
  bun run build
  bin/rails db:prepare
  exec bin/rails test
fi

echo "=== Running in development mode ==="

# TODO(human): Add initial sync process from /sync to /main for tmpfs setup
# Copy necessary files from host (/sync) to tmpfs (/main) excluding directly mounted dirs

# Ensure writable directories exist
mkdir -p ./tmp ./vendor ./node_modules

# Configure bundler to install gems under project vendor path and include all groups
bundle config set --local path 'vendor/bundle' || true
bundle config set --local without '' || true

# Install Ruby/JS dependencies
bundle install --jobs "${BUNDLE_JOBS:-4}"
bun install

# Rails app prep
bin/rails tmp:clear
bin/rails db:prepare

# Karafka web UI DB (best-effort)
bundle exec karafka-web migrate || true

# Start dev processes
exec bin/dev
