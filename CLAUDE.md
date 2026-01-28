# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Umaxica App (JIT)** is a Rails 8 monolithic web application serving as a comprehensive identity, authentication, and communication platform. The application serves multiple business domains (corporate, service, staff) through a single codebase using namespace isolation.

## Development Commands

### Setup
```bash
# Start Docker infrastructure (PostgreSQL, Valkey, Kafka, monitoring stack)
docker compose up

# Install dependencies
bundle install
pnpm install

# Database setup (create, migrate, seed)
bin/rails db:prepare

# Start development server (web, CSS, background jobs)
bin/dev
```

### Testing
```bash
# Run full test suite (parallelized)
bundle exec rails test

# Run tests with coverage (SimpleCov)
COVERAGE=true bin/rails test

# Run specific test file
bundle exec rails test test/models/user_test.rb

# Run single test by line number
bundle exec rails test test/models/user_test.rb:42
```

### Linting & Formatting
```bash
# Ruby style checks
bundle exec rubocop

# Auto-fix Ruby style issues
bundle exec rubocop -a

# ERB template linting
bundle exec erb_lint .

# JavaScript/TypeScript formatting and linting (Biome)
pnpm run check
```

### Database Operations
```bash
# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# View pending TODOs and deployment tasks
bin/rails notes
```

### Asset Management
```bash
# Clear compiled assets
bin/rails assets:clobber

# Watch and compile Tailwind CSS
bin/rails tailwindcss:watch
```

## Architecture & Design Patterns

### Namespace Isolation Strategy

The application uses **namespace isolation** to serve multiple hosts from a single Rails application. Each public host maps to dedicated controller namespaces:

- **Apex** (`Top::Com/App/Org`) - Marketing and preference management (www.umaxica.{com,app,org})
- **Sign** (`Sign::App/Org`) - Identity and authentication services (sign.umaxica.{app,org})
- **Core** (`Core::*`) - Regional edge endpoints and API (a{jp,us}.umaxica.net)
- **Help** (`Help::Com/App/Org`) - Contact and support forms
- **Docs** (`Docs::*`) - Documentation platform
- **News** (`News::*`) - Newsroom

Routes are organized in separate files under `config/routes/` and drawn in `config/routes.rb` using `draw :namespace`.

### Multi-Database Architecture

The application uses **multiple PostgreSQL databases** to isolate data by domain, with primary/replica support:

| Base Class | Databases | Purpose |
|------------|-----------|---------|
| `IdentitiesRecord` | identity, identity_replica | Users, staff, authentication |
| `GuestRecord` | guest, guest_replica | Anonymous contacts |
| `OccurrenceRecord` | occurrence, occurrence_replica | OTPs, identifiers |
| `TokensRecord` | token, token_replica | JWT tokens, sessions |
| `ProfilesRecord` | profile, profile_replica | User preferences |
| `BusinessesRecord` | business, business_replica | Business data |

Models inherit from the appropriate base class to target specific databases. All tables use **UUIDv7 primary keys** for time-ordered inserts.

### Authentication Architecture

The application supports multiple authentication methods:

1. **WebAuthn (Passkeys)** - FIDO2 passkeys via webauthn gem
   - Challenge/verify endpoints in `Sign::App::Setting::PasskeysController`
   - Challenges stored in session, credentials in `UserPasskey` model

2. **JWT (Token-based)** - For native mobile apps
   - Handled via `Authn` concern (`generate_access_token`, `log_in`, `log_out`)
   - Access/refresh tokens stored as secure cookies

3. **OTP (One-Time Password)** - Email and SMS verification
   - HOTP tokens generated via ROTP gem
   - `AwsSmsService` handles SMS delivery (AWS SNS, Infobip, test driver)

4. **TOTP (Time-based OTP)** - Authenticator apps
   - QR code generation via RQRCode
   - Encrypted secrets in `TimeBasedOneTimePassword` model

5. **OAuth** - Social login (Google, Apple)
   - OmniAuth integration

All authentication flows reset sessions and validate bot mitigation (Cloudflare Turnstile).

### Shared Concerns

Cross-cutting functionality lives in controller concerns under `app/controllers/concerns/`:

- `Auth::Base`, `Auth::User`, `Auth::Staff` - Authentication logic
- `PreferenceRegions` - Language, region, timezone preferences
- `Theme` - Dark/light/system theme management
- `Cookie` - ePrivacy cookie consent
- `Redirect` - Safe redirect validation
- `OTP` - One-time password flows
- `CSRF` - CSRF token handling
- `CloudflareTurnstile` - Bot mitigation
- `SessionLimitGate` - Concurrent session limits
- `WebAuthn::Config`, `WebAuthn::SessionChallenge` - Passkey flows
- `RateLimit` - Rate limiting via Rack::Attack

### Service Layer

Business logic is encapsulated in service objects under `app/services/`:

- `AccountService` - Account lifecycle management
- `SocialAuthService` - OAuth flow orchestration
- `AwsSmsService` - SMS delivery provider abstraction
- `AvatarService` - Profile picture management
- `TaxonomyBuilder` - Category/tag management
- `TokenEmergencyService` - Emergency token recovery
- `DocumentVersionWriter`, `TimelineVersionWriter` - Versioning logic

## Configuration & Environment

### Critical Environment Variables

The application is **heavily environment-driven**. Key variables:

```bash
# WebAuthn configuration (REQUIRED for all Rails commands)
TRUSTED_ORIGINS=http://sign.app.localhost:3000,http://sign.org.localhost:3000

# Host mappings (examples)
TOP_CORPORATE_URL=https://www.umaxica.com
TOP_SERVICE_URL=https://www.umaxica.app
AUTH_SERVICE_URL=https://sign.umaxica.app

# Database URLs for each cluster
DATABASE_URL=postgresql://...
IDENTITY_DATABASE_URL=postgresql://...
GUEST_DATABASE_URL=postgresql://...
# (and more for token, profile, business, etc.)

# Redis/Valkey
VALKEY_HOST_PORT=56379

# Kafka/Karafka
KAFKA_BROKERS=localhost:9092
```

See `docker/core/env` for local development defaults.

### Important Configuration Files

- `config/database.yml` - Multi-database configuration with primary/replica support
- `config/initializers/` - 26+ initializers including:
  - `webauthn.rb` - WebAuthn/FIDO2 configuration
  - `omniauth.rb` - OAuth strategy configuration
  - `jwt.rb` - JWT token settings
  - `opentelemetry.rb` - Observability instrumentation
  - `rack_attack.rb` - Rate limiting rules
  - `session_store.rb` - Session configuration
  - `cors.rb` - CORS policy
- `karafka.rb` - Kafka consumer configuration
- `Procfile.dev` - Foreman process definitions (web, css, job worker)

## Logging & Observability

The application uses **structured logging** via ActiveSupport::Notifications:

```ruby
# DO use Rails.event for structured logging
Rails.event.record("event.name", { key: "value" })
Rails.event.error("error.message", error: exception)

# DON'T use Rails.logger for application logs
Rails.logger.info "Something happened"  # Avoid this
```

Logs are machine-parseable and flow to Loki. OpenTelemetry instrumentation sends traces to Tempo.

Health check endpoints exist for all namespaces: `/health` and `/v1/health`

## Security Practices

### Defense in Depth

- **Session Security** - Signed cookies, JWT tokens, session limits
- **CSRF Protection** - Token validation on state-changing requests
- **Bot Mitigation** - Cloudflare Turnstile integration
- **Rate Limiting** - Rack::Attack (1,000 req/hour per client default)
- **Encryption** - Active Record encryption for sensitive columns
- **Password Hashing** - Argon2 and Bcrypt
- **Modern Browsers Only** - `allow_browser versions: :modern` enforced
- **Input Validation** - Strong params, model validations
- **Secret Scanning** - git-secrets via Lefthook pre-commit hooks

### Credentials Management

```bash
# Edit credentials (requires master key)
bin/rails credentials:edit

# Credentials key is shared separately (not in git)
# Cryptographic keys stored in Cloud KMS
```

## Frontend Architecture

### Asset Pipeline

- **Propshaft** - Modern asset pipeline (no Sprockets)
- **Import Maps** - ESM imports without bundlers
- **Tailwind CSS** - Utility-first CSS framework
- **Stimulus** - Lightweight JavaScript framework
- **Turbo** - AJAX/SPA-like navigation with morphdom
- **Biome** - Fast JavaScript linter/formatter

### JavaScript Organization

Entry point: `app/javascript/application.js`

View-specific scripts organized under `app/javascript/views/`:
- `views/sign/app/application.ts` - Sign-in flows
- `views/passkey.js` - WebAuthn integration
- `views/www/**` - Marketing site interactions

Stimulus controllers in `app/javascript/controllers/`

## Testing Strategy

### Test Organization

Tests organized by layer:
- `test/models/` - Model unit tests
- `test/controllers/` - Controller integration tests
- `test/services/` - Service object tests
- `test/policies/` - Pundit authorization tests
- `test/integration/` - End-to-end tests
- `test/fixtures/` - Test data

### Test Configuration

- Framework: **Minitest** (Rails default)
- Coverage: **SimpleCov** with branch coverage enabled
- Database: Transactional tests (can disable with `SKIP_DB=1`)
- Tools: Test Prof (profiling), Prosopite (N+1 detection), Committee (OpenAPI contracts)

Coverage reports generated in `coverage/` directory.

## Development Environment Limitations

**Subdomain Cookie Limitation**: In development using `localhost`, cookies cannot be shared across subdomains (e.g., between `app.localhost:3000` and `help.app.localhost:3000`) due to browser security restrictions. This does not affect test or production environments. Consider using `.test` domain with `/etc/hosts` for subdomain cookie sharing.

## Deployment & Infrastructure

### Docker Compose Stack

The `compose.yml` defines local infrastructure:
- **PostgreSQL 18** (primary + replica)
- **Valkey 8.0** (Redis-compatible)
- **Kafka + Zookeeper** (message streaming)
- **SeaweedFS** (S3-compatible storage)
- **Grafana, Loki, Tempo** (observability stack)

### Cloud Platforms

- **Google Cloud** - Cloud Run, Cloud Build, Cloud Storage, Artifact Registry
- **Cloudflare** - R2 storage, CDN, Tunnel, Turnstile
- **Fastly** - CDN and edge caching
- **AWS** - SNS (SMS), Connect, Polly, SES (email)

### Infrastructure as Code

Terraform manages infrastructure. Lefthook pre-commit hooks include:
- YAML formatting (yamlfmt)
- Terraform linting (tflint)
- Dockerfile linting (hadolint)
- Secret scanning (git-secrets)

## Common Patterns

### Creating a New Controller Namespace

1. Add route file in `config/routes/namespace.rb`
2. Draw it in `config/routes.rb` with `draw :namespace`
3. Create controller under `app/controllers/namespace/`
4. Add views under `app/views/namespace/`
5. Add host constraint and URL environment variable
6. Add helper module in `app/helpers/namespace/`

### Adding a New Database Cluster

1. Create base class inheriting from `ApplicationRecord` (e.g., `XyzRecord`)
2. Configure `connects_to` with primary and replica
3. Add database URLs to `config/database.yml`
4. Create migrations under `db/xyz_migrate/`
5. Update `db:prepare` and `db:migrate` tasks

### Working with Preferences

User preferences (language, region, timezone, theme) are stored in:
1. Signed cookies (`__Secure-root_app_preferences`)
2. Session data (for current request)
3. Database (for authenticated users)

The `PreferenceRegions` and `Theme` concerns handle normalization and persistence.

## Ruby & Rails Version

- **Ruby 4.0.1** (latest major version)
- **Rails 8.x** (main branch from GitHub - bleeding edge)

This uses unreleased Rails features. Be aware of potential API changes.

## Package Management

- **Backend**: Bundler 4.0+ (ships with Ruby 4.0)
- **Frontend**: pnpm 10.27.0 (specified in package.json)

Always use `pnpm` for JavaScript dependencies, not npm or yarn.

## Process Management

Local development uses **Foreman** (`bin/dev`) which runs:
- Web server (Puma on port 3000)
- CSS compilation (Tailwind watch mode)
- Background job worker (Solid Queue)

In production, these run as separate services.
