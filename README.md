[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)

Multi-domain Rails 8.2 application organized around three audience tiers — **app** (end users),
**org** (staff), and **com** (corporate/public) — with host-constrained routing per domain.

## Environments & Endpoints

| Tier                     | Primary Hosts                         | Locale/Section Hosts |
| :----------------------- | :------------------------------------ | -------------------: | ---- | --------------------------- |
| `com` (corporate/public) | `www.umaxica.com`                     |           `www.[news | help | docs].[jp\|us].umaxica.com` |
| `app` (end users)        | `www.umaxica.app`, `sign.umaxica.app` |  `www.[jp\|us].[docs | help | news].umaxica.app`          |
| `org` (staff)            | `www.umaxica.org`, `sign.umaxica.org` |  `www.[jp\|us].[docs | help | news].umaxica.org`          |

## Getting Started

### Prerequisites

| Tool                    |   Version    |                             Notes |
| :---------------------- | :----------: | --------------------------------: |
| Ruby                    |   `4.0.1`    |                     See `Gemfile` |
| Bundler                 | Ruby-bundled |                                   |
| Node.js                 |     20+      |                                   |
| pnpm                    |  `10.27.0`   |                See `package.json` |
| Docker / Docker Compose |    Latest    | Required for local infrastructure |

### Quick Start

```bash
docker compose up -d        # PostgreSQL 18, Valkey, Kafka, SeaweedFS, observability stack
bundle install
pnpm install
bin/rails db:prepare         # Create, migrate, seed all databases
bin/dev                      # Web server + Tailwind watcher + SolidQueue jobs
```

For first-time setup in one command:

```bash
bin/setup
```

### Local Domains (Development)

This app uses host-constrained routing in development. Access each surface with these hosts:

| Surface  | URL Pattern                                  |            Notes |
| :------- | :------------------------------------------- | ---------------: |
| App top  | `http://app.localhost:3000`                  |         end-user |
| Com top  | `http://com.localhost:3000`                  | corporate/public |
| Org top  | `http://org.localhost:3000`                  |            staff |
| App sign | `http://sign.app.localhost:3000`             |  passkey sign-in |
| Org sign | `http://sign.org.localhost:3000`             |  passkey sign-in |
| Docs     | `http://docs.[app\|com\|org].localhost:3000` |  content surface |
| Help     | `http://help.[app\|com\|org].localhost:3000` |  content surface |
| News     | `http://news.[app\|com\|org].localhost:3000` |  content surface |

`*.localhost` resolves to `127.0.0.1` by default in modern environments, so `/etc/hosts` updates are
usually unnecessary.

### Required Environment Variables

`TRUSTED_ORIGINS` is mandatory. The application fails fast at boot when this is missing or empty.

Create/update `.env` with at least:

```bash
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000
```

### WebAuthn

WebAuthn/FIDO2 flows use `TRUSTED_ORIGINS` as a comma-separated allowlist. Example for production:

```bash
TRUSTED_ORIGINS=https://sign.umaxica.app,https://sign.umaxica.org
```

### Secrets & Credentials

- All sensitive configuration lives in **Rails encrypted credentials**
  (`config/credentials/*.yml.enc`). Development and test credentials are shared with team members as
  needed — the encryption key will be provided separately.
- Cryptographic keys are managed via **Cloud KMS**.
- Never commit plaintext credentials. CI runs [Gitleaks](https://github.com/gitleaks/gitleaks) to
  detect accidental credential exposure.

## Development

### Linting & Formatting

```bash
bundle exec rubocop -a       # Ruby auto-fix
bundle exec erb_lint .       # ERB templates
pnpm run check               # JS (oxlint + oxfmt, CI-safe)
```

### Testing

```bash
bundle exec rails test                                    # Full suite
bundle exec rails test test/models/user_test.rb           # Single file
bundle exec rails test test/models/user_test.rb -n test_validation  # Single test
SKIP_DB=1 bundle exec rails test test/unit/               # Unit tests without DB
COVERAGE=true bundle exec rails test                      # With coverage report
```

### Security

```bash
bundle exec brakeman --no-pager           # Static analysis
bundle exec bundler-audit check --update  # Dependency audit
pnpm audit                                # JS dependency audit
trivy fs .                                # Container & filesystem vulnerability scan
```

### Git Hooks (Lefthook)

```bash
lefthook run pre-commit
lefthook run pre-push
```

## Logging

This application uses Rails 8.1's built-in structured logging. All log output is JSON-formatted.

Use `Rails.event.notify` instead of `Rails.logger` for application logging:

```ruby
# Basic event
Rails.event.notify("user.created", user_id: user.id, plan: "pro")

# With tags
Rails.event.tagged("auth") do
  Rails.event.notify("login.success", user_id: user.id)
end

# With request-scoped context
Rails.event.set_context(request_id: request.request_id, ip: request.remote_ip)
```

## Troubleshooting

| Problem                                     | Fix                                                                                                                                                                                                                                        |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Frontend assets not updating                | `bin/rails assets:clobber` then rebuild                                                                                                                                                                                                    |
| Tests failing on missing databases          | `bin/rails db:create`                                                                                                                                                                                                                      |
| Devcontainer fails to start                 | Rebuild the devcontainer                                                                                                                                                                                                                   |
| Cannot decrypt credentials                  | The encryption key is shared separately from the repo                                                                                                                                                                                      |
| Cookies not shared across subdomains in dev | Browser security prevents cookie sharing on `localhost` subdomains (e.g. `app.localhost` vs `help.app.localhost`). This does not affect test or production. Use a `.test` domain with `/etc/hosts` if subdomain sharing is needed locally. |

## Disclaimer

- This project is a work in progress.
- Public availability of this repository is not guaranteed permanently.
- No warranty is provided. The authors shall not be held liable for any damages arising from the use
  of this repository.
