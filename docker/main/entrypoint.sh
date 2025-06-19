#!/bin/bash
set -e

bin/rails tmp:clear
bin/rails db:create
bin/rails db:migrate
# bin/rails db:seed
bin/dev
bundle exec karafka-web migrate

exec "$@"