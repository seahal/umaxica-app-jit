# Umaxica App (JIT) - Feature Overview

This document explains what you can do with the Umaxica App (JIT).

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Domain-Specific Features](#domain-specific-features)
- [Security Features](#security-features)
- [Technical Capabilities](#technical-capabilities)

## Overview

Umaxica App (JIT) is an integrated platform built on Ruby on Rails 8.0 with a sophisticated multi-domain, multi-database architecture. It provides corporate websites, service applications, and staff management interfaces in a single application, featuring modern authentication technologies and comprehensive security features.

### Supported Domains

- **Corporate (.com)**: Corporate site - `www.umaxica.com`, `help.umaxica.com`, `docs.umaxica.com`, `news.umaxica.com`
- **Service (.app)**: Service application - `www.umaxica.app`, `sign.umaxica.app`, `help.umaxica.app`, `docs.umaxica.app`, `news.umaxica.app`
- **Staff (.org)**: Staff management - `www.umaxica.org`, `sign.umaxica.org`, `help.umaxica.org`, `docs.umaxica.org`, `news.umaxica.org`

## Key Features

### 1. Advanced Authentication System

#### Passwordless Authentication
- **WebAuthn (Passkeys)**: 
  - Biometric authentication (fingerprint, facial recognition)
  - Physical security key support (YubiKey, etc.)
  - Secure authentication without passwords

#### One-Time Passwords (OTP)
- **Email Authentication**: 
  - Verification code delivery via email
  - Time-limited tokens
- **SMS Authentication**: 
  - Verification code delivery via phone
  - AWS SNS and Infobip provider support

#### Time-Based Authentication (TOTP)
- **Authenticator App Integration**: 
  - Support for Google Authenticator, Authy, and similar apps
  - Easy setup via QR codes
  - 6-digit one-time code generation

#### Social Login
- **Apple Sign In**: Login with Apple account
- **Google OAuth**: Login with Google account

#### Recovery Codes
- Emergency access when authentication devices are lost
- Generation and management of single-use codes

### 2. User Management

#### Registration System
- **Email Registration**: 
  - Email verification flow
  - Bot prevention with Cloudflare Turnstile
  - Encrypted data storage
- **Telephone Registration**: 
  - SMS verification flow
  - E.164 format phone number validation
  - Multiple SMS provider support

#### Account Settings
- Profile information management
- Security settings modification
- Add/remove authentication methods
- Account withdrawal functionality

### 3. Contact & Support System

#### Contact Forms
- **Email Inquiries**: 
  - Structured inquiry forms
  - Automatic reply email delivery
  - Inquiry history storage
- **Telephone Inquiries**: 
  - Phone support intake forms
  - Callback request functionality

#### Security Measures
- Bot protection with Cloudflare Turnstile
- Spam prevention via rate limiting
- IP address logging

### 4. Preference Management

#### Regional Settings
- **Language Selection**: Japanese and English support
- **Region Selection**: Japan, United States, and other regions
- **Timezone**: User timezone configuration

#### Display Settings
- **Theme Selection**: 
  - Light mode
  - Dark mode
  - Follow system settings
- **Cookie Settings**: 
  - Functional cookies
  - Performance cookies
  - Targeting cookies
  - ePrivacy-compliant consent management

### 5. API & BFF Endpoints

#### Public API
- **Health Checks**: 
  - `/health` (HTML)
  - `/v1/health` (JSON)
- **Email Validation**: 
  - `/v1/inquiry/valid_email_addresses`
  - Validation of Base64-encoded addresses
- **Phone Number Validation**: 
  - `/v1/inquiry/valid_telephone_numbers`
  - E.164 format number validation

#### Backend for Frontend (BFF)
- Preference APIs
- Locale and region configuration APIs
- Client endpoints without authentication requirements

### 6. Documentation & News

#### Documentation Portal
- `docs.umaxica.*` domains
- Technical documentation delivery
- Version-controlled documentation

#### News Portal
- `news.umaxica.*` domains
- Announcements and update information
- Region-specific content (Japan/US)

## Domain-Specific Features

### Corporate (.com) - Corporate Site

**Target Audience**: General users, prospects

**Features**:
- Company information
- Service introduction
- Contact forms
- Help center
- Documentation access
- News and announcements

### Service (.app) - Service Application

**Target Audience**: Registered users

**Features**:
- User registration and login (fully implemented)
  - Email registration
  - Telephone registration
  - Google OAuth registration
  - Passwordless authentication
- Account settings
  - Passkey management
  - TOTP configuration
  - Recovery code management
- Service-specific features
- Help and support
- Documentation access

### Staff (.org) - Staff Management

**Target Audience**: Internal staff, administrators

**Features**:
- Staff registration (basic functionality)
  - Email registration
  - Telephone registration
- Staff authentication (basic functionality only, authentication flow not implemented)
- Management console access
- Security settings
  - Passkey management
  - Recovery code management
- Back-office functionality

## Security Features

### Authentication & Authorization

#### Multi-Factor Authentication (MFA)
- WebAuthn (Passkeys)
- TOTP (Authenticator apps)
- SMS codes
- Email codes

#### Token Management
- **JWT (ES256)**: 
  - Short-lived access tokens (15 minutes)
  - Long-lived refresh tokens (1 year)
  - Encrypted storage
  - Token rotation

#### Session Management
- Signed cookies (HTTP-only, Secure)
- SameSite attribute configuration
- Session timeout
- Multiple device support

### Data Protection

#### Encryption
- **Database Encryption**: 
  - Email addresses
  - Phone numbers
  - OTP secrets
  - Personal information
- **Deterministic Encryption**: Searchable fields
- **Active Record Encryption**: Rails standard encryption features

#### Privacy
- **GDPR Compliance**: 
  - Cookie consent management
  - Right to erasure
  - Data portability
- **ePrivacy Compliance**: EU region privacy regulations

### Security Measures

#### Rate Limiting
- 1,000 requests per hour (default)
- Valkey (Redis-compatible) based limiting
- Per-endpoint control

#### Bot Protection
- Cloudflare Turnstile integration
- Registration and contact form protection
- IP-based filtering

#### Password Hashing
- Argon2 algorithm
- Strong hash function

#### Security Headers
- HSTS (HTTP Strict Transport Security)
- CSRF protection
- Content Security Policy
- X-Frame-Options

### Auditing & Logging

#### Structured Logging
- Event recording via `Rails.event`
- JSON-formatted structured logs
- OpenTelemetry integration

#### Audit Logs
- User action recording
- Staff action recording
- Retention of 180+ days

## Technical Capabilities

### Architecture

#### Multi-Database Configuration
The application uses 10 independent PostgreSQL databases:

1. **identity**: Authentication and identity information
2. **universal**: Universal identifiers and user data
3. **guest**: Guest contact information and communication
4. **profile**: User profiles and preferences
5. **token**: Session and authentication tokens
6. **business**: Business logic and entities
7. **speciality**: Domain-specific features
8. **notification**: Notification management
9. **cache**: Application caching (Solid Cache)
10. **queue**: Background job queue (Solid Queue)

Each database is configured with primary/replica for high availability.

#### Micro-Frontend
- **Bun.js**: Fast JavaScript/TypeScript bundler
- **Turbo**: Hybrid of server-side rendering and SPA
- **React**: Interactive UI components
- **Tailwind CSS**: Utility-first CSS framework

### Performance

#### Caching Strategy
- **Solid Cache**: Database-backed cache
- **Valkey**: Memory-based cache (Redis-compatible)
- **CDN Integration**: 
  - Fastly
  - Cloudflare R2

#### Optimizations
- Asset precompilation
- HTTP/2 support
- Response compression
- Database query optimization

### Background Processing

#### Job Queue
- **Solid Queue**: Database-backed job queue
- **Karafka**: Kafka-based messaging (currently disabled)

#### Asynchronous Processing
- Email delivery
- SMS delivery
- Notification dispatch
- Data processing

### Observability

#### Monitoring
- **OpenTelemetry**: Distributed tracing
- **Grafana**: Dashboards
- **Loki**: Log aggregation
- **Tempo**: Trace storage

#### Health Checks
- `/health` and `/v1/health` available on all endpoints
- CDN monitoring integration
- Uptime monitoring

### External Service Integration

#### Email Delivery
- AWS SES
- Resend
- Twilio SendGrid

#### SMS Delivery
- AWS SNS
- Infobip
- Test provider

#### Cloud Platforms
- **Google Cloud**: 
  - Cloud Run (application execution)
  - Cloud Build (CI/CD)
  - Cloud Storage (file storage)
  - Artifact Registry (container registry)
- **Cloudflare**: 
  - R2 (object storage)
  - Turnstile (bot protection)
  - DNS management
- **Fastly**: CDN and edge computing

### Developer Experience

#### Local Development
- Infrastructure setup with Docker Compose
- Process management with Foreman
- Hot reload support
- Integrated development environment

#### Code Quality
- **Ruby**: RuboCop (Omakase Rails configuration)
- **JavaScript/TypeScript**: Biome (format and lint)
- **ERB**: ERB Lint
- **Security**: 
  - Brakeman (static analysis)
  - Bundler Audit (dependency audit)
- **Git Hooks**: Lefthook (pre-commit checks)

#### Testing
- **Ruby**: Minitest (parallel execution support)
- **JavaScript/TypeScript**: Bun test
- Coverage measurement (SimpleCov)
- Continuous integration (GitHub Actions)

## Future Enhancements

### Planned Features

1. **Kafka-Based Email Delivery**: 
   - Encrypted payloads
   - ActionMailer integration

2. **Content Management**: 
   - CRUD functionality for docs/news
   - Staff/admin editing interface

3. **Authorization System**: 
   - Policy checks via Pundit
   - Permission helper methods

4. **OpenAPI Specification**: 
   - Auto-generation with Rswag
   - `/api-docs` endpoint

5. **CDN Cache Management**: 
   - Automatic purge via Fastly API
   - Immediate reflection of content updates

6. **Personalization**: 
   - Geolocation-based
   - Cookie-based
   - Implementation after privacy review

## Summary

Umaxica App (JIT) is an enterprise-grade web application platform that adopts modern technology stacks and security best practices. It integrates multiple domains and services, providing a scalable and maintainable architecture.

### Key Benefits

- **Security-First**: Modern authentication technologies and encryption
- **Scalability**: Multi-database and replica configuration
- **Observability**: OpenTelemetry and structured logging
- **Developer Experience**: Modern toolchain
- **Compliance**: GDPR and ePrivacy support

### Support

For detailed technical documentation, refer to:
- `README.md`: Setup guide
- `CLAUDE.md`: Architecture details
- `docs/srs.md`: Software requirements specification
- `docs/hld.md`: High-level design document
- `SECURITY.md`: Security policy
