[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml) ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)
（ ＾ν＾） Hello, World!

## Prerequisites

- Ruby 4.0+ (see `Gemfile` for the exact version)
  - Bundler 4.0+ (shipped with modern Ruby installations)
- pnpm 10.x + Node 20+ (for JavaScript tooling)
- Docker (local infrastructure parity)
  - Access to PostgreSQL, Valkey (Redis-compatible), and Kafka instances

## Initial Setup
0. Set up Docker compose and run it: `docker compoe up`
1. Install Ruby dependencies: `bundle install`
2. Install JavaScript/TypeScript dependencies: `pnpm install`
3. Prepare the database (creates, migrates, seeds as`
4. ... run `bin/dev`

## WebAuthn configuration
- WebAuthn requires a `TRUSTED_ORIGINS` environment variable that enumerates every allowed origin. Without it, Rails commands such as `bin/rails db:migrate` cannot start.
- For local development we already set `TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000` inside `docker/core/env`. If you run Ruby commands outside the container, set the same value (or other hosts you use) beforehand.

## Database IDs
- PostgreSQL primary keys default to `bigint` so inserts remain time-ordered.

## Testing
- Rails test suite (parallelized): `bundle exec rails test`
- Coverage can be calculated (or measured) when you execute the test suite using the command `COVERAGE=true bin/rails test.`

## Linting & Formatting
- Ruby style checks: `bundle exec rubocop`
- ERB templates: `bundle exec erb_lint .`
- Frontend formatting and linting: `pnpm run check`

## Logging
- Rails emits structured logs via `Rails.event` (ActiveSupport::Notifications) rather than `Rails.logger`.
- Use `Rails.event.record("event.name", payload_hash)` or `Rails.event.error(...)` so logs stay machine-parseable.

## Key Services & Integrations
- Data and messaging: PostgreSQL, Valkey (Redis), Kafka
- Default infrastructure ports: Valkey exposed on host port 56379 (override with `VALKEY_HOST_PORT`)
- Email and Telecomunication:
  - Resend
  - AWS SES
- Content delivery Network
  - Cloudflare (R2)
  - Fastly CDN
  - Google Cloud Cloud DNS
- Cloud platforms:
  - Google Cloud (Cloud Run, Cloud Build, Cloud Storage, Artifact Registry, OAuth)
  - Apple (Social login)
- Infrastructure as Code: Terraform (including TCP Terraform modules)

## Tooling & Automation

- Pre-commit automation: [Lefthook](https://github.com/evilmartians/lefthook)
- YAML formatting: [yamlfmt](https://github.com/google/yamlfmt)
- Terraform linting: [tflint](https://github.com/terraform-linters/tflint)
- Dockerfile linting: [hadolint](https://github.com/hadolint/hadolint)
- Git secret scanning: [git-secrets](https://github.com/awslabs/git-secrets)

## Deployment & Operations

- Review `bin/rails notes` for pending deployment tasks or TODOs.
- Terraform manages infrastructure for Google Cloud, Cloudflare, Fastly, and supporting services.
- Monitor CI status via the integration workflow badge above.

## Environments & Endpoints
  - Corporate site:
    - `www.umaxica.com`
    - `www.news.[jp|us].umaxica.com`
    - `www.help.[jp|us].umaxica.com`
    - `www.docs.[jp|us].umaxica.com`
  - Service endpoints:
    - `www.umaxica.app`
    - `sign.umaxica.app`
    - `www.[jp|us].docs.umaxica.app`
    - `www.[jp|us].help.umaxica.app`
    - `www.[jp|us].news.umaxica.app`
  - Staff site:
    - `www.umaxica.org`
    - `sign.umaxica.org`
    - `www.[jp|us].docs.umaxica.org`
    - `www.[jp|us].help.umaxica.org`
    - `www.[jp|us].news.umaxica.org`
  - Network endpoints:
    - `a[jp|us].umaxica.net`

## Secrets & Credentials
- Store sensitive configuration in Rails credentials. Development and test credentials are available to team members as needed.
- Run `git-secrets --scan` (hooked via Lefthook) before committing to prevent accidental secret leakage.
- We store our cryptographic keys in Cloud KMS.

## Troubleshooting
- Frontend assets not updating: `bin/rails assets:clobber` followed by a rebuild.
- Tests failing due to missing databases: `bin/rails db:create`
- If your devcontainer fails to start, rebuilding it might resolve the issue.
- The credentials key will be shared with you separately.

## Useful References
- [Official Ruby on Rails Guides](https://rubyonrails.org/)
- [RubyGem](https://rubygems.org/)
- [Rails Security Checklist](https://github.com/eliotsykes/rails-security-checklist)

## Known Issues & Limitations
- This is a work in progress.
- The public availability of this repository is not guaranteed permanently.
- No warranty is provided, and the authors shall not be held liable for any damages arising from the use of this repository.
- **Development Environment Cookie Limitation**: In the development environment using `localhost`, cookies cannot be shared across subdomains (e.g., between `app.localhost:3000` and `help.app.localhost:3000`) due to browser security restrictions. This limitation does not affect test or production environments. If subdomain cookie sharing is required during development, consider using a `.test` domain with `/etc/hosts` configuration.
