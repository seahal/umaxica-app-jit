#!/usr/bin/env bash
set -euo pipefail

USER_ID="$(id -u)"
GROUP_ID="$(id -g)"
GLIBC_VERSION="$(ldd --version | head -n1 | awk '{print $NF}')"
BUNDLE_GLIBC_MARKER="vendor/.glibc-version"
IS_DEVCONTAINER="${DEVCONTAINER_AUTO_START_BIN_DEV:-0}"

run_or_warn() {
  local description="$1"
  shift
  if "$@"; then
    return 0
  fi

  local exit_code=$?
  if [[ "${IS_DEVCONTAINER}" == "1" ]]; then
    echo "Warning: ${description} failed (exit ${exit_code}); continuing because devcontainer mode"
    return 0
  fi

  return "${exit_code}"
}

wait_for_tcp() {
  local host="$1"
  local port="$2"
  local timeout="${3:-60}"

  if [[ -z "${host}" ]]; then
    return 1
  fi

  for ((i = 0; i < timeout; i++)); do
    if bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  return 1
}

# Ensure writable directories exist
for path in ./tmp ./vendor ./node_modules; do
  mkdir -p "${path}"
  sudo chown -R "${USER_ID}:${GROUP_ID}" "${path}"
done

# Wait for critical services when available.
declare -A DB_HOSTS=()
for var in POSTGRESQL_UNIVERSAL_PUB POSTGRESQL_CONTACT_PUB POSTGRESQL_IDENTIFIER_PUB POSTGRESQL_PROFILE_PUB \
           POSTGRESQL_TOKEN_PUB POSTGRESQL_BUSINESS_PUB POSTGRESQL_MESSAGE_PUB POSTGRESQL_NOTIFICATION_PUB \
           POSTGRESQL_CACHE_PUB POSTGRESQL_SPECIALITY_PUB POSTGRESQL_STORAGE_PUB POSTGRESQL_UNIVERSAL_SUB \
           POSTGRESQL_CONTACT_SUB POSTGRESQL_IDENTIFIER_SUB POSTGRESQL_PROFILE_SUB POSTGRESQL_TOKEN_SUB \
           POSTGRESQL_BUSINESS_SUB POSTGRESQL_MESSAGE_SUB POSTGRESQL_NOTIFICATION_SUB POSTGRESQL_CACHE_SUB \
           POSTGRESQL_SPECIALITY_SUB POSTGRESQL_STORAGE_SUB; do
  host="${!var:-}"
  [[ -n "${host}" ]] && DB_HOSTS["${host}"]=1
done

DB_READY=1
for host in "${!DB_HOSTS[@]}"; do
  if wait_for_tcp "${host}" "${POSTGRESQL_PORT:-5432}" 60; then
    continue
  fi

  if [[ "${IS_DEVCONTAINER}" == "1" ]]; then
    echo "Warning: PostgreSQL host ${host}:${POSTGRESQL_PORT:-5432} unreachable; skipping database setup"
    DB_READY=0
  else
    echo "Error: PostgreSQL host ${host}:${POSTGRESQL_PORT:-5432} unreachable"
    exit 1
  fi
done

REDIS_READY=1
if [[ -n "${VALKEY_URL:-}" ]]; then
  redis_endpoint="${VALKEY_URL#*://}"
  redis_host="${redis_endpoint%%:*}"
  redis_port_part="${redis_endpoint#*:}"
  redis_port="${redis_port_part%%/*}"

  if ! wait_for_tcp "${redis_host}" "${redis_port:-6379}" 30; then
    if [[ "${IS_DEVCONTAINER}" == "1" ]]; then
      echo "Warning: Redis ${redis_host}:${redis_port:-6379} unreachable; skipping Redis-dependent tasks"
      REDIS_READY=0
    else
      echo "Error: Redis ${redis_host}:${redis_port:-6379} unreachable"
      exit 1
    fi
  fi
fi

# Clear vendor bundle if native extensions were built against another glibc version.
if [[ -d vendor/bundle ]]; then
  RECORDED_GLIBC=""
  if [[ -f "${BUNDLE_GLIBC_MARKER}" ]]; then
    RECORDED_GLIBC="$(<"${BUNDLE_GLIBC_MARKER}")"
  fi
  if [[ "${RECORDED_GLIBC}" != "${GLIBC_VERSION}" ]]; then
    echo "Detected glibc mismatch (current: ${GLIBC_VERSION}, cached: ${RECORDED_GLIBC:-none}); clearing vendor/bundle"
    sudo rm -rf vendor/bundle
    mkdir -p vendor/bundle
    sudo chown -R "${USER_ID}:${GROUP_ID}" vendor
  fi
fi

# Install Ruby/JS dependencies
bundle install --jobs "${BUNDLE_JOBS:-4}"
bun install

# Record glibc version that the bundle was built against so we can detect drift later.
if [[ -d vendor ]]; then
  printf '%s' "${GLIBC_VERSION}" > "${BUNDLE_GLIBC_MARKER}"
fi

# Development setup
sudo chown -R "${USER_ID}:${GROUP_ID}" /usr/local/bundle/
sudo chown -R "${USER_ID}:${GROUP_ID}" /usr/local/lib/node_modules/ || true

# Rails app prep
if [[ "${DB_READY}" == "1" && "${REDIS_READY}" == "1" ]]; then
  run_or_warn "bin/rails db:create" bin/rails db:create
  run_or_warn "RAILS_ENV=development bin/rails db:migrate" env RAILS_ENV=development bin/rails db:migrate
  run_or_warn "RAILS_ENV=test bin/rails db:migrate" env RAILS_ENV=test bin/rails db:migrate
  run_or_warn "bin/rails db:seed" bin/rails db:seed
else
  echo "Skipping Rails database setup; required services are unavailable"
fi

# Karafka web UI DB (best-effort)
if [[ "${REDIS_READY}" == "1" ]]; then
  run_or_warn "bundle exec karafka-web migrate" bundle exec karafka-web migrate
else
  echo "Skipping Karafka Web migration; Redis is unavailable"
fi

# Clear tmp files
if [[ "${REDIS_READY}" == "1" ]]; then
  run_or_warn "bin/rails tmp:clear" bin/rails tmp:clear
fi

# Hand control back to the requested command (defaults to a long-lived sleep).
if [[ $# -eq 0 ]]; then
  set -- sleep infinity
fi

exec "$@"
