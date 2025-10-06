#!/usr/bin/env bash
set -euo pipefail

USER_ID="$(id -u)"
GROUP_ID="$(id -g)"

# Ensure writable directories exist
for path in ./tmp ./vendor ./node_modules; do
  mkdir -p "${path}"
  sudo chown -R "${USER_ID}:${GROUP_ID}" "${path}"
done

# Install Ruby/JS dependencies
bundle install --jobs "${BUNDLE_JOBS:-4}"
bun install

# Development setup
sudo chown -R "${USER_ID}:${GROUP_ID}" /usr/local/bundle/
sudo chown -R "${USER_ID}:${GROUP_ID}" /usr/local/lib/node_modules/ || true

# Rails app prep
bin/rails db:create
RAILS_ENV=development bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate
bin/rails db:seed

# Karafka web UI DB (best-effort)
bundle exec karafka-web migrate || true

# Clear tmp files
bin/rails tmp:clear

sleep infinity
