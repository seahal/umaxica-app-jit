#!/usr/bin/env bash
set -euo pipefail

APP_ROOT=${APP_ROOT:-/main}
cd "$APP_ROOT"

log() {
  printf '[devcontainer] %s\n' "$*"
}

wait_for_postgres() {
  local host="${1:-${POSTGRESQL_UNIVERSAL_PUB:-primary}}"
  local port="${2:-${POSTGRESQL_PORT:-5432}}"
  local user="${POSTGRESQL_USER:-root}"
  local attempts=0
  local max_attempts=${3:-60}

  log "Waiting for PostgreSQL at ${host}:${port}..."
  until pg_isready -h "$host" -p "$port" -U "$user" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      log "PostgreSQL did not become ready in time."
      exit 1
    fi
    sleep 2
  done
  log "PostgreSQL is ready."
}

mkdir -p tmp log vendor node_modules

bundle config set --local path 'vendor/bundle' || true
bundle config set --local without '' || true
bundle config set --local force_ruby_platform 'true' || true

export BUNDLE_FORCE_RUBY_PLATFORM=${BUNDLE_FORCE_RUBY_PLATFORM:-1}

wait_for_postgres

if ! bundle check >/dev/null 2>&1; then
  log "Installing Ruby gems..."
  bundle install --jobs "${BUNDLE_JOBS:-4}"
fi

ensure_openssl() {
  if bundle exec ruby -ropenssl -e 'exit 0' >/dev/null 2>&1; then
    return
  fi

  log "Rebuilding openssl gem for current platform..."
  if ! bundle pristine openssl >/dev/null 2>&1; then
    bundle install --jobs "${BUNDLE_JOBS:-4}"
  fi

  if ! bundle exec ruby -ropenssl -e 'exit 0' >/dev/null 2>&1; then
    log "Warning: openssl gem still failing to load; please run 'bundle pristine openssl' manually."
  else
    log "OpenSSL gem rebuilt successfully."
  fi
}

ensure_openssl

if [ -f bun.lock ] || [ -f package.json ]; then
  log "Installing Bun packages..."
  bun install --frozen-lockfile || bun install
fi

log "Preparing database..."
bin/rails db:prepare

if [ ! -f tmp/.devcontainer-seeded ]; then
  log "Seeding database..."
  if bin/rails db:seed; then
    touch tmp/.devcontainer-seeded
  else
    log "Database seed failed (continuing)."
  fi
fi

log "Migrating Karafka Web UI (best effort)..."
bundle exec karafka-web migrate || true

log "Clearing tmp..."
bin/rails tmp:clear

auto_start=${DEVCONTAINER_AUTO_START_BIN_DEV:-1}
if [ "${DEVCONTAINER_IDE:-}" = "jetbrains" ] || [ "${JETBRAINS_REMOTE_DEV:-}" = "true" ]; then
  auto_start=0
fi

if [ "$#" -gt 0 ]; then
  exec "$@"
elif [ "$auto_start" = "0" ]; then
  log "Auto-start disabled; keeping container idle."
  exec tail -f /dev/null
else
  exec bin/dev
fi
