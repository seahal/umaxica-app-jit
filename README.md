=[![CI](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit/actions/workflows/integration.yml) ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit/main)

# Umaxica App (JIT)
（ ＾ν＾） Hello, World!

## Prerequisites

- Ruby 3.4.7 (defined in the `Gemfile`)
- Bundler 2.5+ (shipped with modern Ruby installations)
- Bun 1.3.x (plus Node.js 20+ if a package requires Node APIs)
- Docker (recommended for local infrastructure parity)
- Access to PostgreSQL, Valkey (Redis-compatible), and Kafka instances

## Initial Setup

1. Install Ruby dependencies: `bundle install`
2. Install JavaScript/TypeScript dependencies: `bun install`
3. Prepare the database (creates, migrates, seeds as needed): `bin/rails db:prepare`
4. ... run `bin/dev`

## Local Development
- Run the full development stack (`web`, `Karafka`, watchers, etc.): `foreman start -f Procfile.dev`
- Alternatively, launch the Rails server directly: `bin/rails s -p 3000 -b 0.0.0.0`
- Watch and rebuild assets during development: `bun run build --watch`

## Testing

- Rails test suite (parallelized): `bundle exec rails test`
- JavaScript/TypeScript tests: `bun test`

## Linting & Formatting

- Ruby style checks: `bundle exec rubocop`
- ERB templates: `bundle exec erb_lint .`
- Frontend formatting and linting: `bun run format`, `bun run lint`
- Type checking: `bun run typecheck`

## Key Services & Integrations

- Data and messaging: PostgreSQL, Valkey (Redis), Kafka
- Default infrastructure ports: Valkey exposed on host port 56379 (override with `VALKEY_HOST_PORT`)
- Email and Telecomunication:
  - Resend
  - Twilio
  - AWS SES
- Content delivery Network
  - Cloudflare (R2)
  - Fastly CDN
- Cloud platforms:
  - Google Cloud (Cloud Run, Cloud Build, Cloud Storage, Artifact Registry, OAuth)
  - Apple (Social login)
- Infrastructure as Code: Terraform (including TCP Terraform modules)
- Sentry ... ?

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
    - `www.umaxica.app`
    - `api.[jp|us].umaxica.com`
    - `news.[jp|us].umaxica.com`
    - `docs.[jp|us].umaxica.com` 
    - `news.[jp|us].umaxica.com`
  - Service endpoints:
    - `www.umaxica.app`
    - `sign.umaxica.app`
    - `api.[jp|us].umaxica.app`
    - `docs.[jp|us].umaxica.app`
    - `help.[jp|us].umaxica.app`
    - `news.[jp|us].umaxica.app`
  - Staff site:
    - `www.umaxica.org`
    - `sign.umaxica.org`
    - `api.[jp|us].umaxica.org`
    - `docs.[jp|us].umaxica.org`
    - `help.[jp|us].umaxica.org`
    - `news.[jp|us].umaxica.org`
  - Network endpoints:
    - `asset-[jp|us].umaxica.net` ... NOTE: This endopoints are not run on Ruby on Rails

## Secrets & Credentials
- Store sensitive configuration in Rails credentials. Development and test credentials are available to team members as needed.
- Run `git-secrets --scan` (hooked via Lefthook) before committing to prevent accidental secret leakage.

## Useful References
- [Official Ruby on Rails Guides](https://rubyonrails.org/)
- [RubyGem](https://rubygems.org/)
- [Rails Security Checklist](https://github.com/eliotsykes/rails-security-checklist)

## Troubleshooting
- Frontend assets not updating: `bin/rails assets:clobber` followed by a rebuild.
- Tests failing due to missing databases: `bin/rails db:create`

## Known Issues & Limitations
- This is a work in progress.
- The public availability of this repository is not guaranteed permanently.
- No warranty is provided, and the authors shall not be held liable for any damages arising from the use of this repository.
