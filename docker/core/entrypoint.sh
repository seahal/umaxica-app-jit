#!/usr/bin/env bash
set -euo pipefail

#
bundle config set path 'vendor/bundle'

# Install Ruby/JS dependencies
bun install
bundle install

# Rails app prep
bin/rails tmp:clear
bin/rails db:create
bin/rails db:migrate
RAILS_ENV=test bin/rails db:create
RAILS_ENV=test bin/rails db:migrate
bin/rails db:seed

# Karafka web UI DB (best-effort)
# bundle exec karafka-web migrate || true

#
sudo chown -R 1000:1000 ../
sudo rm -rf ../.npm

#
exec "$@"
