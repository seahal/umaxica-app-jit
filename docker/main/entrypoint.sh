#!/bin/bash
set -e

# package install
bundle install
bun install

# for Database setup
bin/rails tmp:clear
bin/rails db:create
bin/rails db:migrate
# bin/rails db:seed

# for Karafka
bundle exec karafka-web migrate

# run servers
bin/dev

exec "$@"