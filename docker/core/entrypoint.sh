#!/usr/bin/env bash
set -euo pipefail

#
bundle config set path 'vendor/bundle'

# Ensure log and tmp directories are writable
sudo mkdir -p log tmp
sudo chown -R 1000:1000 log tmp
sudo chmod -R 0775 log tmp

# Create log files with correct permissions before Rails starts
touch log/development.log log/test.log log/production.log 2>/dev/null || true
sudo chown 1000:1000 log/*.log 2>/dev/null || true
sudo chmod 0664 log/*.log 2>/dev/null || true

# Install Ruby/JS dependencies
bun install
bundle install

# Rails app prep
bin/rails tmp:clear

bin/rails db:create
bin/rails db:migrate
RAILS_ENV=test bin/rails db:create
bin/rails db:seed
# RAILS_ENV=test bin/rails db:seed

# Karafka web UI DB (best-effort)
# bundle exec karafka-web migrate || true

#
sudo chown -R 1000:1000 ../
sudo rm -rf ../.npm

#
exec "$@"
