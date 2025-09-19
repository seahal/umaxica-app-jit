#!/usr/bin/env bash
set -euo pipefail

# Working dir should be /main from Dockerfile, but ensure
cd "${APP_ROOT:-/main}"

# Ensure writable directories exist
mkdir -p ./tmp ./vendor ./node_modules

# Install Ruby/JS dependencies
bundle install --jobs "${BUNDLE_JOBS:-4}"
bun install

# Rails app prep
bin/rails tmp:clear
bin/rails db:prepare
bin/rails db:migrate
bin/rails db:seed

# Karafka web UI DB (best-effort)
bundle exec karafka-web migrate || true

# ???
sleep infinity