[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)

Multi-domain Rails 8.2 application organized around three audience tiers — **app** (end users),
**org** (staff), and **com** (corporate/public) — with host-constrained routing per domain.

## Environments & Endpoints

### Corporate Site

- `www.umaxica.com`
- `www.news.[jp|us].umaxica.com`
- `www.help.[jp|us].umaxica.com`
- `www.docs.[jp|us].umaxica.com`

### Service Endpoints

- `www.umaxica.app`
- `sign.umaxica.app`
- `www.[jp|us].docs.umaxica.app`
- `www.[jp|us].help.umaxica.app`
- `www.[jp|us].news.umaxica.app`

### Staff Site

- `www.umaxica.org`
- `sign.umaxica.org`
- `www.[jp|us].docs.umaxica.org`
- `www.[jp|us].help.umaxica.org`
- `www.[jp|us].news.umaxica.org`

### Network Endpoints

- `a[jp|us].umaxica.net`

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
docker compose up -d        # PostgreSQL 18, Valkey, Kafka, observability stack
bundle install
pnpm install
bin/rails db:prepare         # Create, migrate, seed all databases
bin/dev                      # Web server + Tailwind watcher + SolidQueue jobs
```

For first-time setup in one command:

```bash
bin/setup
```

### Development Checks

Use the project wrappers so local tooling runs with repository defaults:

```bash
bin/rubocop
bin/brakeman
bin/debride
```

`bin/debride` runs with Rails-aware analysis against `app/models`, `app/services`, `app/jobs`, and
`app/policies`. Override the noise floor with `DEBRIDE_MINIMUM=5 bin/debride`, or pass paths
explicitly such as `bin/debride app/services`.

### Local Domains (Development)

This app uses host-constrained routing in development. Access each surface with these hosts:

| Surface  | URL Pattern                                  |                 Notes |
| :------- | :------------------------------------------- | --------------------: |
| App apex | `http://app.localhost:3000`                  |      end-user surface |
| Com apex | `http://com.localhost:3000`                  | corporate/preferences |
| Org apex | `http://org.localhost:3000`                  |         staff surface |
| App sign | `http://sign.app.localhost:3000`             |       passkey sign-in |
| Org sign | `http://sign.org.localhost:3000`             |       passkey sign-in |
| App core | `http://www.app.localhost:3000`              |           main app UI |
| Com core | `http://www.com.localhost:3000`              |          corporate UI |
| Org core | `http://www.org.localhost:3000`              |              staff UI |
| Docs     | `http://docs.[app\|com\|org].localhost:3000` |       content surface |
| Help     | `http://help.[app\|com\|org].localhost:3000` |       content surface |
| News     | `http://news.[app\|com\|org].localhost:3000` |       content surface |

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
- Never commit plaintext credentials. CI runs [Gitleaks](https://github.com/gitleaks/gitleaks) to
  detect accidental credential exposure.

### External Services

- **Google OAuth** for social sign-in.
- **AWS** for SMS delivery via SNS.
- **Cloudflare** for Turnstile and R2-based asset delivery.
- **Fastly** for cache purge and edge delivery support.
- **Sentry** for error monitoring.
- **Amazon SES** for SMTP-based email delivery.

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

Rails 8.1 structured logging is enabled. Application logs are JSON and should use
`Rails.event.notify` rather than `Rails.logger`.

```ruby
Rails.event.notify("user.created", user_id: user.id, plan: "pro")
Rails.event.tagged("auth") do
  Rails.event.notify("login.success", user_id: user.id)
end
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
