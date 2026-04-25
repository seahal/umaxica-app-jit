[![CI](https://github.com/seahal/umaxica-apps-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-apps-jit/actions/workflows/integration.yml)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-apps-jit/main)

# Umaxica App (JIT)

（ ＾ν＾） Hello, World!

## Abstract

Umaxica App (JIT) is a multi-domain Ruby on Rails application that serves three audience surfaces
through host-constrained routing: **app** for end users, **org** for staff and operators, and
**com** for corporate and public-facing content. The application covers authentication (passkeys,
TOTP, social login), content management, preference handling, and operational tooling across
isolated PostgreSQL databases. The frontend is built with Hotwire (Turbo + Stimulus) and delivered
through Importmap without a JavaScript bundler.

## Repository Information

- `app/`: application code, controllers, models, views, and shared services
- `config/`: framework configuration, routes, environments, and database settings
- `db/`: schema dumps and migration directories for each database
- `docs/`: current documentation and operational reference
- `plans/`: proposals, migration plans, phased work, and future changes
- `adr/`: accepted architecture and design decision records
- `test/`: Minitest suites, fixtures, and shared test support
- `docker/`: container and local environment support files

## Database

Normative deployment-scope matrix:

| Scope      | Name           | Purpose                    |
| :--------- | :------------- | :------------------------- |
| Global     | `principal`    | User identity              |
| Global     | `operator`     | Staff management           |
| Global     | `token`        | Authentication tokens      |
| Global     | `preference`   | User and staff preferences |
| Global     | `occurrence`   | Rate limiting              |
| Global     | `avatar`       | User profiles              |
| Global     | `activity`     | Global audit logs          |
| Global     | `notification` | Notifications              |
| Global     | `guest`        | Guest contacts             |
| Local      | `document`     | CMS documents              |
| Local      | `news`         | News and blog posts        |
| Local      | `behavior`     | Regional behavior logs     |
| Local      | `message`      | Messages                   |
| Local      | `search`       | Regional search            |
| Local      | `billing`      | Billing                    |
| Local      | `storage`      | Active Storage files       |
| Per-Deploy | `queue`        | Solid Queue jobs           |

Rules: `Global` is shared worldwide and must not store regional content bodies or regional
compliance details. `Local` is region-specific and must be isolated per region. `Per-Deploy` is
infrastructure-only. Base record comments and `config/database.yml` must match this matrix.

## Stack

- **Ruby** `3.4.9`
  - **Rails** edge (pin the version explicitly once the project moves to beta)
  - **Sorbet** runtime type checking via `sorbet-runtime`
  - **Bundler** for gem dependency management
- **Database**
  - **PostgreSQL** `18+`
    - Multi-database architecture with write (pub) and read replica (sub) connections per database
    - See [Database](#database) for the normative deployment-scope matrix
  - **Solid Queue** — job queue backed by the `queue` database
  - **Valkey** — in-memory store (port `56379`)
- **Authentication and security**
  - WebAuthn / FIDO2 for passkeys
  - OmniAuth for social login (Apple, Google)
  - Cloudflare Turnstile for bot protection (standard and stealth modes)
  - Pundit for authorization policies
  - ActiveRecord Encryption for sensitive data
  - Argon2 and bcrypt for password hashing
- **Frontend**
  - This repository does not use a JavaScript bundler
  - **Importmap** (`importmap-rails`) for browser-side JavaScript delivery
  - **Hotwire** (Turbo + Stimulus) for interactivity
    - Stimulus controllers live in `app/javascript/controllers/`
  - **Tailwind CSS** via `tailwindcss-rails`
  - **Propshaft** for static asset serving (not Sprockets)
- **Frontend tooling** (`vp`)
  - `vp` is the entrypoint for JavaScript and frontend tooling commands
  - Wraps **pnpm**, **Vitest**, **Oxlint**, and **Oxfmt** through Vite+
  - `vp install` — install JavaScript dependencies
  - `vp check` — run formatting, linting, and type checks
  - `vp test` — run JavaScript tests (located in `test/javascript/`)
  - `vp pm audit` — audit JavaScript packages
  - Do not use `pnpm`, `npm`, or `yarn` directly for routine work
  - Do not use `vp build` to produce Rails browser assets

## Local Setup

- Docker and Docker Compose
- Ruby `3.4.9`
- Bundler
- Node.js `20+`
- `pnpm@10.27.0`

Docker Compose starts the following services:

- **PostgreSQL 18** — primary and replica with WAL streaming
- **Valkey** — in-memory store (port `56379`)
- **SeaweedFS** — S3-compatible object storage
- **Grafana, Loki, and Tempo** — observability stack
- **Cloudflare Tunnel**

Start the local stack, install dependencies, and boot the app:

```bash
docker compose up
bundle install
vp install
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000 bin/setup
```

`TRUSTED_ORIGINS` is required for boot because WebAuthn origin validation fails fast when it is
missing. `docker/core/env` defaults to production sign domains, so override it locally in your shell
or dev env file.

`bin/setup` installs Ruby gems, runs `bin/rails db:prepare`, clears logs and temp files, then starts
`bin/dev`. It does not install JavaScript packages, so run `vp install` first.

If dependencies are already installed, you can start development directly:

```bash
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000 bin/dev
```

`bin/dev` runs `bin/rails db:prepare` unless `SKIP_DB_PREPARE=1`, then starts:

- `web`: Rails server on port `3000`
- `css`: `bin/rails tailwindcss:watch`
- `job`: `bin/jobs start`

## Development URLs

Modern browsers resolve `*.localhost` to `127.0.0.1`, so extra `/etc/hosts` entries are usually not
needed.

| Engine     | Surface | URL                                        |
| :--------- | :------ | :----------------------------------------- |
| Zenith     | Acme    | `http://www.{app,com,org}.localhost:3000`  |
| Signature  | Sign    | `http://sign.{app,com,org}.localhost:3000` |
| Foundation | Base    | `http://base.{app,com,org}.localhost:3000` |
| Publisher  | Post    | `http://post.{app,com,org}.localhost:3000` |

## Testing, Security, and Quality

- **Testing**
  - Ruby tests use Minitest with fixtures (`test/`)
  - JavaScript tests use Vitest (`test/javascript/`)
  - Run Ruby tests: `bundle exec rails test`
  - Run a single file: `bundle exec rails test test/models/user_test.rb`
  - Run with coverage: `COVERAGE=true bundle exec rails test`
  - Run JavaScript tests: `vp test`
  - Run JavaScript tests in watch mode: `vp test --watch`
- **Linting and formatting**
  - Ruby: `bundle exec rubocop` (auto-fix with `-a`)
  - ERB: `bundle exec erb_lint .` (auto-fix with `-a .`)
  - JavaScript: `vp check` (auto-fix with `--fix`)
- **Security scanning**
  - Static analysis: `bundle exec brakeman --no-pager`
  - Gem audit: `bundle exec bundler-audit check --update`
  - Importmap audit: `bin/importmap audit`
  - JavaScript package audit: `vp pm audit`
- **Developer workflow**
  - Pre-commit hooks are managed by **Lefthook**
  - Lefthook runs configured checks automatically before each commit
  - Configuration: `lefthook.yml`
  - Install hooks: `lefthook install`
  - Run manually: `lefthook run pre-commit`
- **CI** (GitHub Actions)
  - Runs on push to `develop` / `main` and on pull requests
  - Jobs: actionlint, hadolint, Brakeman, bundler-audit, gitleaks, Semgrep, RuboCop, erb_lint, Rails
    test suite (PostgreSQL 18 + Valkey), Biome, package audit, container image scanning (Trivy +
    Grype)
- **Database consistency**
  - `bundle exec database_consistency`
- **Logging**
  - Application logging is structured through `Rails.event`
  - Prefer `Rails.event.record` for domain events and `Rails.event.error` for failures
  - Do not use `Rails.logger` for new application logging when structured logging is available
  - Example:
    ```ruby
    Rails.event.record("user.created", user_id: user.id)
    Rails.event.tagged("auth") { Rails.event.record("login.success", user_id: user.id) }
    ```

## Troubleshooting

| Problem                                  | Fix                                                                                   |
| :--------------------------------------- | :------------------------------------------------------------------------------------ |
| Tailwind changes are not reflected       | Run `bin/rails assets:clobber` and restart `bin/dev` or `bin/rails tailwindcss:watch` |
| Tests fail because databases are missing | Run `bin/rails db:prepare`                                                            |
| `bin/dev` stops during boot              | Check `TRUSTED_ORIGINS` and database availability                                     |
| Git operations fail around hooks         | Run `lefthook install` to set up pre-commit hooks                                     |
| Credentials cannot be decrypted          | Use the shared Rails credentials key for this environment                             |

## Acknowledgement

- Secrets must stay in Rails credentials; do not commit plaintext secrets.
- WebAuthn origins are controlled by `TRUSTED_ORIGINS`.
- Public availability of this repository is not guaranteed permanently.
