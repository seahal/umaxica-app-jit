#!/usr/bin/env bash
set -euo pipefail

#
bundle config set path 'vendor/bundle'

# Ensure writable directories exist
#mkdir -p ./tmp ./vendor ./node_modules
#sudo chown -R 1000:1000 /home/jit/vendor
#sudo chown -R 1000:1000 /home/jit/node_modules
sudo rm -rf /home/jit/.npm

## Install Ruby/JS dependencies
bun install
bundle install --jobs "${BUNDLE_JOBS:-4}"

# Development setup
# sudo chown -R 1000:1000 /usr/local/bundle/
# sudo chown -R 1000:1000 /usr/local/lib/node_modules/

## Rails app prep
bin/rails tmp:clear
bin/rails db:prepare
bin/rails db:seed

## Karafka web UI DB (best-effort)
#bundle exec karafka-web migrate || true

#
exec "$@"
