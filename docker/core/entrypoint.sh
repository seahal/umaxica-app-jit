#!/usr/bin/env bash
set -euo pipefail

#
bundle config set path 'vendor/bundle'

# Install Ruby/JS dependencies
bun install
bundle install

# Rails app prep
bin/rails tmp:clear
RAILS_ENV=test bin/rails db:prepare
bin/rails db:seed

# Karafka web UI DB (best-effort)
# bundle exec karafka-web migrate || true

#
exec "$@"
