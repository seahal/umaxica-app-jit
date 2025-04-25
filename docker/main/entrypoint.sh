#!/bin/bash
set -e

rm -f docker/tmp/pids/server.pid

bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/dev

exec "$@"