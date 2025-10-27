# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Rails 8.0 application with a sophisticated multi-domain, multi-database architecture:

### Domain Structure
- **WWW (Web Interface)**: Three distinct domains serving different user types
  - `WWW_CORPORATE_URL` (com): Corporate/client site
  - `WWW_SERVICE_URL` (app): Main service application
  - `WWW_STAFF_URL` (org): Staff administration interface
- **API**: Corresponding API endpoints for each domain
  - `API_CORPORATE_URL`, `API_SERVICE_URL`, `API_STAFF_URL`
- **Additional Services**: docs, news endpoints

### Multi-Database Setup
The application uses 10+ separate PostgreSQL databases with primary/replica configurations:
- `universal` - Universal identifiers and user data
- `identifier` - Authentication and identity management
- `guest` - Guest contact information and communication
- `profile` - User profiles and preferences
- `token` - Session and authentication tokens
- `business` - Business logic and entities
- `message` - Messaging system
- `notification` - Notification management
- `cache` - Application caching
- `speciality` - Domain-specific features
- `storage` - File storage metadata

Each database has primary/replica pairs with separate migration paths in `db/{database_name}_migrate/`.

### Controller Organization
Controllers are organized by domain module:
- `app/controllers/www/{com,app,org}/` - Web controllers for each domain
- `app/controllers/api/{com,app,org}/` - API controllers for each domain
- `app/controllers/concerns/` - Shared controller logic

### Key Technologies
- **Authentication**: WebAuthn, TOTP, Apple/Google OAuth, recovery codes
- **Authorization**: Pundit + Rolify
- **Background Jobs**: Karafka (Kafka-based)
- **Frontend**: Rails with Bun.js for asset bundling
- **File Uploads**: CarrierWave + Active Storage with Google Cloud Storage
- **Security**: Rack::Attack for rate limiting, argon2 for password hashing
- **Monitoring**: OpenTelemetry instrumentation

## Development Commands

### Setup and Dependencies
```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies (requires Bun)
bun install

# Database setup (requires Docker Compose)
docker compose up -d  # Start PostgreSQL containers
bundle exec rails db:create
bundle exec rails db:migrate
```

### Development Server
```bash
# Start all services (web server, Karafka, asset building)
foreman start -f Procfile.dev.dev

# Or individually:
bundle exec rails server -p 3000 -b '0.0.0.0'
bundle exec karafka server
bun run build --watch
```

### Testing
```bash
# Run all tests
bundle exec rails test

# Run specific test file
bundle exec rails test test/models/user_test.rb

# Run tests for specific controller
bundle exec rails test test/controllers/www/app/authentications_controller_test.rb

# Continuous testing with Guard
bundle exec guard
```

### Code Quality
```bash
# Ruby linting
bundle exec rubocop
bundle exec rubocop --fix

# ERB template linting
bundle exec erblint app/views/

# JavaScript/TypeScript linting and formatting
bun run lint
bun run format
bun run type

# Security scanning
bundle exec brakeman
bundle exec bundler-audit
```

### Database Operations
```bash
# Create migration for specific database
bundle exec rails generate migration CreateUsers --database=identifier

# Run migrations for specific database
bundle exec rails db:migrate:identifier

# Run all database migrations
bundle exec rails db:migrate

# Reset all databases
bundle exec rails db:drop db:create db:migrate
```

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
Models inherit from domain-specific base classes:
- `UniversalRecord` - Universal database
- `IdentifiersRecord` - Identifier database
- `GuestsRecord` - Guest database
- etc.

### View Components
Uses ViewComponent gem for reusable UI components. Components are in `app/components/`.

### Route Organization
Routes are split by domain in `config/routes/`:
- `www.rb` - Web interface routes
- `api.rb` - API endpoint routes
- `docs.rb` - Documentation routes
- `news.rb` - News/content routes

## Environment Variables

Key environment variables required:
- `WWW_CORPORATE_URL`, `WWW_SERVICE_URL`, `WWW_STAFF_URL` - Domain URLs
- `API_CORPORATE_URL`, `API_SERVICE_URL`, `API_STAFF_URL` - API URLs
- `POSTGRESQL_*` - Database connection settings
- `RAILS_MAX_THREADS` - Threading configuration
- `RACK_ATTACK_API_KEY` - API key for Rack::Attack authentication

## Important Notes

- Always run `bundle install` after pulling changes due to frequent gem updates
- Use domain-specific controllers and routes - check the constraint blocks in routes
- Database migrations must specify the correct database with `--database` flag
- Test files follow the domain structure: `test/controllers/{domain}/{subdomain}/`
- Asset compilation uses Bun - ensure Bun is installed locally
- The application expects Docker Compose for local database setup

### 禁止事項
- `.env`ファイルの作成・変更
- `node_modules`内のファイル編集
- テストを実行せずにコミット
- 承認なしでのPRマージ
- test/test_helper.rb の操作は駄目です。
- config/ の操作は許可を取ること。
