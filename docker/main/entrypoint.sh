#!/usr/bin/env bash
set -euo pipefail

# Ensure writable directories exist
mkdir -p ./tmp ./vendor ./node_modules
sudo chown -R 1000:1000 ./vendor
sudo chown -R 1000:1000 ./node_modules

# Install Ruby/JS dependencies
bundle install --jobs "${BUNDLE_JOBS:-4}"
bun install

# Development setup
sudo chown -R 1000:1000 /usr/local/bundle/
sudo chown -R 1000:1000 /usr/local/lib/node_modules/

# Rails app prep
bin/rails tmp:clear
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Karafka web UI DB (best-effort)
bundle exec karafka-web migrate || true

if [[ $# -gt 0 ]]; then
  exec "$@"
fi

exec sleep infinity
