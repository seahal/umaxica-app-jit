# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Build & Run Commands

```bash
# Setup (requires Docker running first)
docker compose up -d              # Start PostgreSQL 18+, Valkey, Kafka, etc.
bundle install                    # Install Ruby gems
pnpm install                     # Install JS dependencies
bin/rails db:prepare             # Create, migrate, seed all databases
bin/dev                          # Start dev server (web + Tailwind watcher + SolidQueue jobs)

# Testing
bundle exec rails test                                    # Full test suite
bundle exec rails test test/models/user_test.rb           # Single file
bundle exec rails test test/models/user_test.rb -n test_validation  # Single test method
SKIP_DB=1 bundle exec rails test test/unit/               # Unit tests without DB
COVERAGE=true bin/rails test                              # With coverage report

# Linting
bundle exec rubocop              # Ruby style
bundle exec rubocop -a           # Ruby auto-fix
bundle exec erb_lint .           # ERB templates
pnpm run check                   # JS/TS (Biome)

# Security
bundle exec brakeman --no-pager
bundle exec bundler-audit check --update

# Utilities
rake uuid:pk:report              # Audit UUIDv7 primary key configs
bin/rails notes                  # Show TODO/FIXME annotations
```

## Architecture

### Application Module: `Jit::Application`

Ruby 4.0.1 / Rails 8.1 (from `rails/rails` main branch). PostgreSQL 18+ required for native
`uuidv7()`.

### Multi-Domain, Multi-Audience Structure

The app serves multiple domains, each split into three audience tiers: **app** (end users), **org**
(staff), **com** (corporate/public). Routes are host-constrained and modularized:

| Route file              | Domain purpose                                     | Hosts (dev)                                                   |
| ----------------------- | -------------------------------------------------- | ------------------------------------------------------------- |
| `config/routes/sign.rb` | Authentication (sign-in/up, MFA, passkeys, social) | `sign.app.localhost`, `sign.org.localhost`                    |
| `config/routes/apex.rb` | Dashboard shell & preferences                      | `app.localhost`, `org.localhost`, `com.localhost`             |
| `config/routes/core.rb` | Main app backend (contacts, content management)    | `www.app.localhost`, `www.org.localhost`, `www.com.localhost` |
| `config/routes/docs.rb` | Documentation delivery                             | `docs.com.localhost`                                          |
| `config/routes/news.rb` | News/blog delivery                                 | news domains                                                  |
| `config/routes/help.rb` | Help system                                        | help domains                                                  |

Controllers mirror this: `app/controllers/sign/app/`, `app/controllers/sign/org/`,
`app/controllers/apex/com/`, etc.

### Multi-Database Architecture (20 databases)

Each database has a write (pub) and read replica (sub) connection. Key databases:

| Database     | Migration dir            | Purpose                      |
| ------------ | ------------------------ | ---------------------------- |
| `principal`  | `db/principals_migrate`  | Users & staff identity       |
| `operator`   | `db/operators_migrate`   | Staff/operator management    |
| `token`      | `db/tokens_migrate`      | Auth tokens (access/refresh) |
| `preference` | `db/preferences_migrate` | User/staff preferences       |
| `guest`      | `db/guests_migrate`      | Guest contacts               |
| `document`   | `db/documents_migrate`   | CMS documents                |
| `news`       | `db/news_migrate`        | News posts                   |
| `activity`   | `db/activity_migrate`    | Audit logs                   |
| `occurrence` | `db/occurrences_migrate` | Rate-limiting events         |
| `avatar`     | `db/avatars_migrate`     | Avatar/social profiles       |
| `queue`      | `db/queues_migrate`      | SolidQueue jobs              |
| `cache`      | `db/caches_migrate`      | SolidCache                   |

Schema files: `db/<name>_schema.rb` (e.g., `db/principal_schema.rb`). The root `db/schema.rb` also
exists.

### Authentication & Security

- **WebAuthn/FIDO2** for passkeys (requires `TRUSTED_ORIGINS` env var for all Rails commands)
- **OmniAuth** for social login (Apple, Google)
- **Cloudflare Turnstile** for bot protection (standard + stealth modes) via `TurnstileConfig` /
  `TurnstileVerifier`
- **Pundit** for authorization policies
- **Rack::Attack** for rate limiting
- **Custom `CsrfValidation` middleware** for API endpoints
- **ActiveRecord Encryption** for sensitive data (keys in Rails credentials)
- **Argon2 + bcrypt** for password hashing

Auth concerns: `Auth::User` (user sessions), `Auth::Staff` (staff sessions), `Auth::Passkey`,
`Auth::StepUp`.

### Frontend

- **Hotwire** (Turbo + Stimulus) with **Importmap** (no bundler)
- **Propshaft** asset pipeline (not Sprockets)
- **Tailwind CSS** via `tailwindcss-rails` gem
- **Biome** for JS linting/formatting
- Stimulus controllers in `app/javascript/controllers/`

### Key Patterns

- **Structured logging**: Use `Rails.event.record("event.name", payload)` instead of `Rails.logger`
- **UUIDv7 primary keys**: Generated by PostgreSQL's native `uuidv7()`, not Rails-side
- **Public IDs**: Models use `PublicId` concern for URL-safe Nanoid identifiers
- **Frozen string literals**: Required in all Ruby files
- **Sorbet**: Runtime type checking via `sorbet-runtime`
- **i18n default locale**: Japanese (`:ja`)

### Test Organization

- `test/unit/` - Unit tests (no DB required, runnable with `SKIP_DB=1`)
- `test/models/` - Model tests (require DB)
- `test/controllers/` - Controller tests (require DB, mirror controller namespaces)
- `test/integration/` - Integration tests (full request stack)
- `test/services/`, `test/jobs/`, `test/mailers/`, `test/policies/` - Domain-specific tests
- `test/support/` - Shared helpers (auth bypass via `X-TEST-CURRENT-USER` / `X-TEST-CURRENT-STAFF`
  headers)
- Test fixtures loaded selectively in `test/test_helper.rb` (not `fixtures :all`)

### Docker Compose Services

PostgreSQL 18 (primary + replica with WAL streaming), Valkey (port 56379), Kafka + Zookeeper,
SeaweedFS (S3-compatible storage), Grafana + Loki + Tempo (observability), Cloudflare Tunnel.

### CI Pipeline (`.github/workflows/integration.yml`)

Runs on push to develop/main and PRs. Jobs: actionlint, hadolint, Brakeman + bundler-audit,
gitleaks, Semgrep, RuboCop + erb_lint, Rails test suite (with Postgres 18 + Valkey + Kafka), Biome +
pnpm audit, container image scanning (Trivy + Grype).

## Requirements Analysis Best Practices

### Verify with multiple sources

Always verify initial understanding against primary sources. Never proceed on assumptions alone.

1. **Hypothesis**: Recognize intuitive understanding as a hypothesis
2. **Primary sources**: Check implementation code (highest trust) > prototypes > specs
3. **Contradictions**: If sources contradict each other, do NOT resolve independently -- report to
   user for decision
4. **Confirm**: Before implementing, output confirmed sources and current understanding as bullet
   points for user agreement
