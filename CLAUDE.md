# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Rails 8.0 application with a sophisticated multi-domain, multi-database architecture.

### Domain Structure
The application consists of multiple endpoints, each with 3 domains (com/app/org):

- **APEX** (formerly TOP): Top pages and preference management
  - `PEAK_CORPORATE_URL` (com): Corporate site top page
  - `PEAK_SERVICE_URL` (app): Service app top page
  - `PEAK_STAFF_URL` (org): Staff management top page

- **SIGN**: Authentication, registration, login, and withdrawal
  - `AUTH_SERVICE_URL` (app): User authentication (fully implemented)
  - `AUTH_STAFF_URL` (org): Staff authentication (basic features only, auth flow not implemented)
  - Supports WebAuthn, TOTP, Apple/Google OAuth

- **CORE**: Backend for Frontend
  - `CORE_CORPORATE_URL` (com): Corporate BFF
  - `CORE_SERVICE_URL` (app): Service BFF
  - `CORE_STAFF_URL` (org): Staff BFF

- **HELP**: Help and contact pages
  - `HELP_CORPORATE_URL`, `HELP_SERVICE_URL`, `HELP_STAFF_URL`

- **DOCS**: Documentation pages
  - `DOCS_CORPORATE_URL`, `DOCS_SERVICE_URL`, `DOCS_STAFF_URL`

- **NEWS**: News pages
  - `NEWS_CORPORATE_URL`, `NEWS_SERVICE_URL`, `NEWS_STAFF_URL`

### Multi-Database Setup
The application uses 10 separate PostgreSQL databases with primary/replica configurations:

**Migration-managed databases** (migration paths: `db/{database_name}_migrate/`):
- `universal` (universals_migrate) - Universal identifiers and user data
- `identity` (identities_migrate) - Authentication and identity management
- `guest` (guests_migrate) - Guest contact information and communication
- `profile` (profiles_migrate) - User profiles and preferences
- `token` (tokens_migrate) - Session and authentication tokens
- `business` (businesses_migrate) - Business logic and entities
- `speciality` (specialities_migrate) - Domain-specific features
- `primary` (migrate) - Primary database

**Schema-only databases** (schema files exist, no migration directory):
- `notification` (notification_schema.rb) - Notification management
- `cache` (cache_schema.rb) - Application caching (Solid Cache)
- `queue` (queue_schema.rb) - Background job queue (Solid Queue)
- `storage` (storage_schema.rb) - File storage metadata

**Notes**:
- Each database is configured as a primary/replica pair in `config/database.yml`
- Database connection names: `{db_name}` (primary), `{db_name}_replica` (replica)
- The `message` database mentioned in old docs does not actually exist

### Controller Organization
Controllers are organized by endpoint module and domain:
- `app/controllers/apex/{com,app,org}/` - Top page controllers
- `app/controllers/sign/{app,org}/` - Authentication controllers
- `app/controllers/core/{com,app,org}/` - BFF controllers
- `app/controllers/help/{com,app,org}/` - Help and contact controllers
- `app/controllers/docs/{com,app,org}/` - Documentation controllers
- `app/controllers/news/{com,app,org}/` - News controllers
- `app/controllers/concerns/` - Shared controller logic
- `app/controllers/{endpoint}/concerns/` - Endpoint-specific concerns

### Key Technologies
- **Authentication**: WebAuthn, TOTP, Apple/Google OAuth, recovery codes
- **Authorization**: Pundit
- **Background Jobs**: Solid Queue (DB-based queue), Karafka (Kafka-based, currently disabled)
- **Frontend**: Rails with Bun.js for asset bundling
- **File Uploads**: Shrine + Active Storage with Google Cloud Storage
- **Security**: Rack::Attack for rate limiting, argon2 for password hashing
- **Monitoring**: OpenTelemetry instrumentation
- **Logging**: Structured logging with Rails.event (ActiveSupport::Notifications)

## Development Commands

### Setup and Dependencies
```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies (requires Bun)
bun install

# Database setup (requires Docker Compose)
docker compose up -d
bundle exec rails db:create db:migrate
```

### Testing
```bash
# Run all tests
bundle exec rails test

# Run specific test file
bundle exec rails test test/models/user_test.rb

# Run specific controller tests
bundle exec rails test test/controllers/sign/app/authentications_controller_test.rb
```

### Database Operations
```bash
# Create migration for specific database (use database key name from database.yml)
bundle exec rails generate migration CreateUsers --database=identity

# Run migrations for specific database
bundle exec rails db:migrate:identity

# Run all database migrations
bundle exec rails db:migrate

# Note: Use database key names from database.yml
# Examples: identity, universal, guest, profile, token, business, speciality
```

## Structured Logging

This application uses structured logging with `Rails.event` (ActiveSupport::Notifications) instead of traditional `Rails.logger.info`.

### Benefits
- **Parseable**: Logs are structured as JSON for easy search and analysis
- **Context**: Automatically includes request ID, user ID, session info
- **Consistency**: All logs follow the same format
- **OpenTelemetry**: Logs are automatically correlated with traces

### Usage

```ruby
# Emit an event
Rails.event.notify("user.login", user_id: user.id, ip_address: request.remote_ip)

# Error events (use notify, not error)
Rails.event.notify("authentication.failed",
  error_class: error.class.name,
  error_message: error.message,
  user_id: user&.id
)

# Debug-only logging
Rails.event.debug("api.request",
  endpoint: request.path,
  method: request.method,
  params: filtered_params
)
```

### Event Naming Convention
Use `{domain}.{action}` format:
- `user.login`, `user.logout` - User authentication
- `staff.login`, `staff.logout` - Staff authentication
- `api.request`, `api.response` - API requests
- `database.query` - Database queries
- `job.enqueue`, `job.perform` - Background jobs
- `security.rate_limit`, `security.suspicious_activity` - Security events

### Important Notes
- **No sensitive data**: Never log passwords, tokens, credit card numbers
- **Use correct method**: Use `Rails.event.notify` (not `record` or `error`)
- **No legacy logger**: Use `Rails.event.notify` instead of `Rails.logger.info`
- **Performance**: Only log necessary information

## Key Patterns

### Model Concerns
Shared model logic is in `app/models/concerns/`:
- `Email` - Email validation and normalization
- `Telephone` - Phone number handling
- `SetId` - ID generation patterns
- `RecoverCode` - Recovery code management

### Authentication Flow
- Multi-factor authentication with WebAuthn, TOTP, recovery codes
- Social login via Apple/Google OAuth
- Session management across multiple domains
- Email/telephone verification workflows

### Database Connections
Models inherit from database-specific base classes:
- `UniversalRecord` - Universal database
- `IdentityRecord` - Identity database (authentication/identity info)
- `GuestRecord` - Guest database (guest contact info)
- `ProfileRecord` - Profile database (user profiles)
- `TokenRecord` - Token database (session/auth tokens)
- `BusinessRecord` - Business database (business logic)
- `SpecialityRecord` - Speciality database (special features)
- `NotificationRecord` - Notification database
- `CacheRecord` - Cache database (Solid Cache)
- `QueueRecord` - Queue database (Solid Queue)
- `StorageRecord` - Storage database (storage metadata)

### View Components
Uses ViewComponent gem for reusable UI components. Components are in `app/components/`.

### Route Organization
Routes are split by endpoint in `config/routes/`:
- `apex.rb` - Top page routes (com/app/org)
- `sign.rb` - Authentication routes (app/org)
- `core.rb` - BFF routes (com/app/org)
- `help.rb` - Help routes (com/app/org)
- `docs.rb` - Documentation routes (com/app/org)
- `news.rb` - News routes (com/app/org)

Each route file uses host constraints (`constraints host:`) to split into 3 domains (com/app/org) and route to corresponding controller modules.

## Environment Variables

Key environment variables required:

### Domain URLs (per endpoint × 3 domains)
- `PEAK_CORPORATE_URL`, `PEAK_SERVICE_URL`, `PEAK_STAFF_URL`
- `AUTH_SERVICE_URL`, `AUTH_STAFF_URL` (no com domain for AUTH)
- `CORE_CORPORATE_URL`, `CORE_SERVICE_URL`, `CORE_STAFF_URL`
- `HELP_CORPORATE_URL`, `HELP_SERVICE_URL`, `HELP_STAFF_URL`
- `DOCS_CORPORATE_URL`, `DOCS_SERVICE_URL`, `DOCS_STAFF_URL`
- `NEWS_CORPORATE_URL`, `NEWS_SERVICE_URL`, `NEWS_STAFF_URL`

### Database Settings
- `POSTGRESQL_USER`, `POSTGRESQL_PASSWORD` - DB credentials
- `POSTGRESQL_*_PUB`, `POSTGRESQL_*_SUB` - Primary/replica hosts per database
  - Example: `POSTGRESQL_UNIVERSAL_PUB`, `POSTGRESQL_UNIVERSAL_SUB`

### Application Settings
- `RAILS_MAX_THREADS` - Threading configuration
- `RACK_ATTACK_API_KEY` - API key for Rack::Attack authentication

## Important Notes

- Always run `bundle install` after pulling changes due to frequent gem updates
- Use domain-specific controllers and routes - check the constraint blocks in routes
- Database migrations must specify the correct database with `--database` flag
- Test files follow the endpoint/domain structure: `test/controllers/{endpoint}/{domain}/`
  - Example: `test/controllers/apex/app/`, `test/controllers/sign/app/`
- Asset compilation uses Bun - ensure Bun is installed locally
- The application expects Docker Compose for local database setup

### Prohibited Actions
- Editing files in `node_modules`
- Committing without running tests
- Merging PRs without approval
- Modifying `test/test_helper.rb`
- Modifying `config/` files without permission

### Coding Standards
- **Logging**: Always use `Rails.event.notify` instead of `Rails.logger.info`
- **Structured logs**: All logs must be structured events
- **Sensitive data**: Never log passwords, tokens, API keys
- **Refresh token rotation**: Always issue new tokens and invalidate old ones when using refresh tokens
