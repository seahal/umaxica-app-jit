[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)

This is a Rails 8 multi-surface application. Routing and implementation are organized around
explicit domain boundaries: `app`, `com`, and `org`.

## Prerequisites

- Ruby `4.0.1` (from `Gemfile`)
- Bundler (Ruby bundled version is fine)
- Node.js 20+
- pnpm `10.27.0` (from `package.json`)
- Docker / Docker Compose (recommended for local infrastructure)

Primary local services (`compose.yml`):

- PostgreSQL 18 (primary / replica)
- Valkey
- Kafka
- SeaweedFS (S3-compatible)
- Grafana / Loki / Tempo (observability)

## Quick Start

1. Install dependencies

```bash
bundle install
pnpm install
```

2. Start local infrastructure (recommended)

```bash
docker compose up -d
```

3. Start the application

```bash
bin/dev
```

`bin/dev` runs database preparation (`bin/rails db:prepare`) and then starts processes defined in
`Procfile.dev`.

For first-time setup in one command:

```bash
bin/setup
```

## WebAuthn

WebAuthn-related flows require `TRUSTED_ORIGINS`. Set allowed origins as a comma-separated
environment variable for the hosts you use.

Example:

```bash
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000
```

## Project Structure

- Application code: `app/` (`models/`, `controllers/`, `services/`, `policies/`, `jobs/`, `views/`)
- Frontend code: `app/javascript/` (Stimulus + importmap)
- Tests: `test/` (Minitest, fixtures)
- Routing: `config/routes.rb`, `config/routes/*.rb`
- Database: `db/` and domain migration directories (for example `db/operators_migrate/`,
  `db/avatars_migrate/`)
- Ops/docs: `docker/`, `compose.yml`, `docs/`, `qa/`

## Development Commands

- Setup: `bin/setup`
- Start dev server: `bin/dev`
- Run tests: `bundle exec rails test`
- Run tests with coverage: `COVERAGE=true bundle exec rails test`
- Ruby lint: `bundle exec rubocop`
- ERB lint: `bundle exec erb_lint --lint-all`
- JS check (format + lint): `pnpm run check`
- Security scan: `bundle exec brakeman --no-pager`

## Hooks / CI Hygiene

Run pre-commit hooks locally:

```bash
lefthook run pre-commit
```

`lefthook.yml` includes checks such as `rubocop`, `erb_lint`, `pnpm check`, `brakeman`,
`rails test`, and `bundler-audit`.

## Notes

- Rails currently tracks the `main` branch (`Gemfile`).
- Store secrets in Rails credentials and never commit plaintext secrets.
