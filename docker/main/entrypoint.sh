#!/usr/bin/env bash
set -euo pipefail

USER_ID="$(id -u)"
GROUP_ID="$(id -g)"

retry() {
  local attempts="$1"
  shift
  local delay="${RETRY_DELAY_SECONDS:-5}"
  local count=1

  while (( count <= attempts )); do
    if "$@"; then
      return 0
    fi

    echo "Retry ${count}/${attempts} failed for '$*'. Sleeping ${delay}s..." >&2
    sleep "${delay}"
    count=$((count + 1))
  done

  return 1
}

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

# Wait for the primary Postgres service before running migrations
DB_HOST="${POSTGRESQL_UNIVERSAL_PUB:-primary}"
DB_PORT="${POSTGRESQL_PORT:-5432}"

if ! retry "${DB_WAIT_ATTEMPTS:-20}" pg_isready -h "${DB_HOST}" -p "${DB_PORT}"; then
  echo "Warning: PostgreSQL at ${DB_HOST}:${DB_PORT} did not report ready. Continuing anyway." >&2
fi

# Rails app prep
bin/rails tmp:clear
bin/rails db:create
RAILS_ENV=development bin/rails db:migrate
RAILS_ENV=test bin/rails db:migrate
bin/rails db:seed

# Karafka web UI DB (best-effort)
bundle exec karafka-web migrate || true

sleep infinity
