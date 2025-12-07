# Detailed Design Specification (DDS)
## Project: Umaxica App (JIT)
### Conforms to IEEE 1016:2009 and ISO/IEC/IEEE 42010:2011

---

## 1. Introduction

### 1.1 Purpose
This DDS translates the high-level design of the Umaxica App (JIT) into implementation-ready detail. It describes how each namespace, controller, concern, model, service, and infrastructure component collaborates to satisfy the SRS.

### 1.2 Scope
- All Rails namespaces within `app/controllers`
- Front-end bundles in `app/javascript`
- Data models spanning the multi-database setup defined in `config/database.yml`
- Supporting services (`app/services`, `app/consumers`, ActionMailer, Sms providers)
- Observability, configuration, and deployment mechanisms (Bun, Compose, Foreman, CI)

### 1.3 References
- `docs/srs.md`, `docs/hld.md`
- `README.md`, `AGENTS.md`, `docs/checklist.md`
- ISO/IEC/IEEE 42010, IEEE 1016

---

## 2. Architectural Context

### 2.1 System Context
The Rails monolith handles seven public surfaces (`top`, `sign`, `help`, `docs`, `news`, `api`, `bff`). Each surface is isolated by host constraints and has its own controllers, yet they share cross-cutting concerns.

```
Browser ⇄ Fastly/Cloudflare ⇄ Rails (Top/Sign/Help/Docs/News/API/BFF)
    ├─ PostgreSQL (identity, guest, universal, token, etc.)
    ├─ Valkey (sessions, rate limit, Memorize)
    ├─ Kafka (email topic via Karafka)
    ├─ ActionMailer + SMTP
    ├─ AwsSmsService → AWS SNS / Infobip
    └─ OpenTelemetry exporter → Tempo / Logs → Loki / Dashboards → Grafana
```

### 2.2 Primary Modules
| Layer | Components |
|-------|------------|
| Presentation | Namespaced controllers and Turbo/React views under `app/javascript` |
| Domain Logic | Concerns in `app/controllers/concerns`, services in `app/services`, models per DB |
| Integration | `app/mailers`, `app/consumers`, `AwsSmsService`, `Karafka`, OTEL instrumentation |
| Infrastructure | Compose services (Postgres, Valkey, Kafka, MinIO, Loki, Tempo, Grafana), Bun/Tailwind build chain |

---

## 3. Module Design

### 3.1 Routing & Namespacing
- `config/routes.rb` only `draw`s partials to keep the file maintainable.
- Each partial inside `config/routes/*.rb`:
  - Scopes traffic via `constraints host: ENV["<HOST_VAR>"]`
  - Adds nested modules (e.g., `scope module: :com, as: :com`)
  - Defines RESTful resources for health endpoints, preferences, docs, API, etc.
- All routes expose `/health` (HTML) and `/v1/health` (JSON) courtesy of controllers mixing in the `Health` concern.

### 3.2 Shared Controller Concerns
| Concern | Key responsibilities |
|---------|---------------------|
| `Authn` | JWT (ES256) issuance/verification, login/logout helpers, refresh cookie handling |
| `RateLimit` | Configures `ActiveSupport::Cache::RedisCacheStore` with Valkey to enforce per-request throttles |
| `DefaultUrlOptions` | Reads signed preference cookie to append `lx`, `ri`, `tz` query params |
| `PreferenceRegions` | Normalizes locale/timezone inputs, persists to session/cookies, handles errors |
| `Theme` | Provides theme editing/updating with shorthand codes and preference cookie syncing |
| `Cookie` | Stores ePrivacy consent flags in signed cookies |
| `CloudflareTurnstile` | Validates Turnstile tokens via HTTP POST |
| `Redirect` | Validates allowed redirect hosts and Base64 tokens |
| `Memorize` | Thin Valkey wrapper (encrypted) for per-session ephemeral storage |
| `Health` | Implements `show_html`/`show_json` for heartbeat endpoints |

### 3.3 Top Namespace
- Controllers under `app/controllers/top/(com|app|org)` extend `ActionController::Base`, include `DefaultUrlOptions`, `PreferenceRegions`, `Theme`, `Cookie`, and `RateLimit` as needed.
- `Top::*::RootsController#index` redirects to `EDGE_*` hosts via `redirect_to "https://#{ENV['EDGE_*_URL']}", allow_other_host: true`.
- `Preference::*` controllers (region, cookie, theme, reset) provide UI for personalization and ePrivacy. Data stored inside signed cookies named `root_<scope>_preferences` and `root_<scope>_theme`.
- Views interact with JS entrypoints in `app/javascript/views/www/**` to show localized text, doc/help/news URLs, etc.

### 3.4 Sign Namespace
**Registration flow** (`app/controllers/sign/app/registration/emails_controller.rb`):
1. `#new`: clears session slot, ensures user not logged in, instantiates `UserIdentityEmail`.
2. `#create`: validates Turnstile, generates HOTP secret + counter, stores intermediate state in session, dispatches OTP via `Email::App::RegistrationMailer`.
3. `#edit`: ensures session data matches requested ID and not expired.
4. `#update`: validates OTP; on success, persists `UserIdentityEmail`, clears session, redirects to home.

**Authentication flow** (`sign/app/authentication`):
- Email login obtains HOTP private key stored in encrypted cookie `:htop_private_key`.
- Passkeys: `PasskeysController` integrates WebAuthn gem; client JS `views/passkey.js` fetches `/setting/passkeys/challenge`, uses `navigator.credentials.create`, and POSTs `/verify`.
- Recoveries and TOTPs live under `sign/app/setting`; TOTPs use `ROTP` and `RQRCode`.
- Sessions: `Sign::App::SessionsController#create` (placeholder) will use `Authn#log_in`.

**Security features**:
- `Sign::*::ApplicationController` mixes in `Authn`, `RateLimit`, `DefaultUrlOptions`, `Pundit`.
- `authenticate_user!` ensures `logged_in?` before hitting settings endpoints.
- JWT cookies: `Authn` writes `cookies[:access_token]` (JWT) and `cookies.encrypted[:refresh_token]` (UUID referencing `UserToken`).

### 3.5 Help Namespace
- `Help::Com::ContactsController` handles `new/create/show`.
- `ServiceSiteContact` (GuestsRecord) encrypts email, phone, title, description; requires either email or telephone plus policy consent.
- Turnstile integration ensures bot mitigation; errors are logged via `Rails.logger`.
- OTP dispatch uses `Email::App::ContactMailer` and `AwsSmsService`.

### 3.6 Docs & News Namespaces
- Mirror the top namespace with simpler controller sets (root + health endpoints).
- React/Turbo entrypoints under `app/javascript/views/docs/**` and `views/news/**` hydrate placeholder content.

### 3.7 API Namespace
- Base controllers inherit from `ActionController::API` for lean responses.
- `Api::App::V1::Inquiry::ValidEmailAddressesController`: `#show` decodes Base64 `params[:id]`, instantiates `ServiceSiteContact` to reuse validation logic, and responds with `valid: true|false`.
- `ValidTelephoneNumbersController`: accepts JSON body, validates via same model.
- Host constraints ensure corporate/service/staff API stacks remain separated.

### 3.8 BFF Namespace
- Targets non-authenticated clients needing preference/email operations without hitting the full Rails views.
- `Bff::Concerns::Regionalization` overrides `default_url_options`, `set_locale`, and `set_timezone` using session or query params.
- Email preference controllers share translation scopes: e.g., `Bff::App::Preference::EmailsController#translation_scope => "bff.app.preferences"`.

### 3.9 Front-End Bundles
- `app/javascript/application.js` imports Turbo and each surface-specific entrypoint.
- Directory structure: `app/javascript/views/<surface>/<domain>/application.(ts|js)` plus shared scripts (`views/passkey.js`, `views/passkey_helpers.js`, `views/www/app/inquiry/before_submit.js`).
- Bun build pipeline (`bun bun.config.js`) discovers `application.js/ts` entries and writes compiled files to `app/assets/builds/**`.
- Tailwind CSS compiled via CLI (`@tailwindcss/cli`) invoked from the same Bun script.

### 3.10 Services & Integrations
- `AwsSmsService` delegates to provider classes under `app/services/sms_providers` (AWS SNS, Infobip, Test). Providers validate parameters and call respective APIs with credentials loaded from Rails credentials.
- Other service placeholders (`AccountService`, `CoreService`, `EntityService`) mark future boundaries (business/customer mgmt, tokens).
- `RedisMemorize` (inside `Memorize`) encrypts values using `ActiveSupport::MessageEncryptor` (derived from `secret_key_base`).

### 3.11 Messaging & Background Work
- `karafka.rb` sets up Karafka app with Kafka brokers (Docker vs local). Topic `:email` maps to `EmailConsumer`.
- `EmailConsumer` currently stubbed; intended design: decrypt payload, instantiate mailer from payload metadata, deliver email; instrumentation via Karafka events.
- Karafka Web UI (enabled at `/karafka` once mounted) exposes consumer metrics.

### 3.12 Observability
- `config/initializers/opentelemetry.rb` loads OTEL SDK, exporter, and instrumentation.
- Production config sets `service_name = "umaxica-app-jit-core"` and `use_all`.
- Development example demonstrates how to point to OTLP endpoint (`tempo:4318`).
- Compose includes Loki/Tempo/Grafana; logs/traces accessible via forwarded ports.

---

## 4. Key Flows

### 4.1 Preference Update (Top::App::Preference::Region)
1. User visits `/preference/region/edit?lx=ja&ri=jp`.
2. `PreferenceRegions#set_edit_variables` normalizes query params, populates `@current_*`.
3. User submits new locale/timezone.
4. `#update` calls `apply_updates` → `assign_if_present` / `update_language` / `update_timezone`.
5. On success, `persist_preference_cookie!` writes signed JSON cookie (`root_app_preferences`).
6. Controller redirects to edit URL with normalized query params.

### 4.2 Email Registration Flow
1. `Sign::App::Registration::EmailsController#new` resets session, renders form.
2. `#create` verifies Turnstile, generates HOTP secret/counter, stores metadata in session, and emails OTP via `Email::App::RegistrationMailer`.
3. User enters OTP → `#update` reuses `UserIdentityEmail` validations; ensures session ID matches and not expired.
4. On success, `UserIdentityEmail` persists to identity DB, session cleared, redirect with success flash.

### 4.3 Help Contact Submission
1. User visits `help.umaxica.com/contacts/new`.
2. Form ensures policy consent via `views/www/app/inquiry/before_submit.js`.
3. `#create` builds `ServiceSiteContact`, ensures Turnstile passes, encrypts PII, and stores IP address.
4. Future: enqueue Kafka payload to `email` topic; currently, send immediate email via `Email::App::ContactMailer`.
5. Redirect back with success notice.

### 4.4 Passkey Enrollment
1. Browser calls `/setting/passkeys/challenge`; controller fetches `User.last`, ensures `webauthn_id`, collects exclude credentials.
2. `WebAuthn::Credential.options_for_create` returns challenge; stored in `session[:webauthn_create_challenge]`.
3. Client JS uses `navigator.credentials.create` with challenge; POSTs `/setting/passkeys/verify`.
4. Server verifies challenge (TODO) and persists `UserPasskey` with `webauthn_id`, `public_key`, `sign_count`.

---

## 5. Data Design

### 5.1 Models & Storage
| Model | Base DB | Notes |
|-------|---------|-------|
| `User`, `Staff` | `IdentitiesRecord` | `has_many :emails`, `:phones`, `webauthn_id` stored |
| `UserIdentityEmail` | `IdentitiesRecord` | Includes `Email` concern, encrypts `address`, `before_create` sets UUID v7 |
| `ServiceSiteContact` | `GuestsRecord` | Encrypts email/phone/title/description, validates OTP codes, stores `ip_address` |
| `TimeBasedOneTimePassword` | `UniversalRecord` | Encrypts `private_key`, stores `last_otp_at`, `first_token` virtual attr |
| `UserPasskey` | `ApplicationRecord` | Validates `webauthn_id`, `public_key`, `description`, `sign_count` |
| `UserToken`, `UserSession` | `TokensRecord` | Reference tokens for JWT refresh handling |
| `IdentifierRegionCode` and join tables | `UniversalRecord` | Future mapping for personas/staff region codes |

### 5.2 Cookies & Sessions
- Preference cookie: `root_app_preferences` (JSON: `lx`, `ri`, `tz`, `ct`).
- Theme cookie: `root_<scope>_theme`.
- Consent cookies: `:accept_functional_cookies`, `:accept_performance_cookies`, `:accept_targeting_cookies`.
- Auth cookies: `:access_token` (JWT), `:refresh_token` (encrypted).
- HOTP private key: `cookies.encrypted[:htop_private_key]`.
- Session: stores preference drafts, OTP metadata, WebAuthn challenges; `Memorize` offers encrypted Valkey storage keyed by host/session.

### 5.3 Redis Usage
- Sessions (if configured) + Rack cache
- Rate limiting store (Valkey)
- Memorize key/value store with encryption
- Potential background job caches when Karafka/ActiveJob expanded

---

## 6. External Interfaces

| Interface | Endpoint(s) | Details |
|-----------|-------------|---------|
| HTTP/Turbo | `/`, `/health`, `/v1/health`, `/preference/*`, `/sign/*`, `/help/contacts`, `/api/v1/inquiry/*`, `/bff/*` | Host-specific responses; `allow_browser` enforces modern clients. |
| Cloudflare Turnstile | `https://challenges.cloudflare.com/turnstile/v0/siteverify` | Called server-side with secret key, form response, and client IP. |
| ActionMailer | `Email::App::RegistrationMailer`, `Email::App::ContactMailer`, etc. | Default sender from credentials `SMTP_FROM_ADDRESS`; uses `mailer/app/mailer` layout. |
| Sms providers | AWS SNS / Infobip / test driver | Called via `AwsSmsService.send_message` with provider-specific client objects. |
| Kafka | topic `email` | `karafka.rb` defines producers/consumers; `EmailConsumer` to process messages. |
| OpenTelemetry | OTLP exporter | Default endpoint `http://tempo:4318/v1/traces` (configurable). |
| Storage | MinIO / Google Cloud Storage | `google-cloud-storage` + `shrine` used for file storage (future). |

---

## 7. Configuration & Environment
- `.env` / credentials must define hostnames (`TOP_*`, `SIGN_*`, `DOCS_*`, `NEWS_*`, `HELP_*`, `BFF_*`, `API_*`, `EDGE_*`, `APEX_*`), DB hosts (`POSTGRESQL_*`), Redis URLs (`REDIS_RACK_ATTACK_URL`, `REDIS_SESSION_URL`), Kafka brokers (`KAFKA_BROKERS`), Cloudflare Turnstile keys, JWT keys, AWS/Infobip credentials, OTLP endpoint.
- `compose.yml` launches all infra dependencies with sensible defaults; volumes store data per service.
- `Procfile.dev` ensures Rails server + Bun watcher (and optionally Karafka) run concurrently.
- Build/test commands:
  - `bundle install`, `bun install`
  - `bin/rails db:prepare`
  - `foreman start -f Procfile.dev`
  - Tests: `bin/rails test`, `bun test`
  - Lint: `bundle exec rubocop`, `bundle exec erb_lint .`, `bun run lint`, `bun run format`, `bun run typecheck`

---

## 8. Security Mechanisms
- **Authentication**: JWT-based session cookies with ES256 keys stored in credentials.
- **Authorization**: Pundit included; settings controllers call `authorize`.
- **Bot mitigation**: Cloudflare Turnstile required for registration/contact forms; server logs failures.
- **Rate limiting**: Configured via `RateLimit` concern (Valkey backend).
- **Data encryption**: Active Record encryption for PII (emails, phones, private keys, titles, descriptions). `ServiceSiteContact` ensures deterministic encryption for lookups where needed.
- **Passkeys & OTP**: WebAuthn for passkeys, ROTP for HOTP/TOTP, RQRCode for QR codes, AwsSmsService for SMS OTP.
- **Redirect safety**: `Redirect::ALLOWED_HOSTS` enumerates acceptable targets; `generate_redirect_url` rejects unknown hosts.
- **Browser allowlist**: `allow_browser versions: :modern` prevents outdated user agents from hitting sensitive surfaces.
- **Secrets management**: Rails credentials provide JWT keys, Turnstile secrets, SMTP and AWS keys; Compose expects sanitized `.env`.

---

## 9. Error Handling & Logging
- `Health` concern logs initialization errors and returns 503/500 when the app is booting or raises exceptions.
- Controllers surface validation errors via flash messages and status codes (`422 Unprocessable Content`).
- Turnstile failures are logged at warn/error level with context.
- `ServiceSiteContact` `before_create` raises if required content missing to prevent blank submissions.
- OTEL instrumentation emits spans for HTTP requests, Redis calls, Karafka events, and ActionMailer deliveries (once instrumentation enabled).
- Logs stream to STDOUT → Loki (when Compose stack used) or platform logging (Cloud Run).

---

## 10. Deployment & Operations
- **Local**: Compose + Foreman; `bun run build --watch` rebuilds assets; `karafka server` can run concurrently.
- **CI**: GitHub Actions pipeline runs bundler install, database setup, Rails tests, Bun tests, linting, Brakeman, Bundler Audit, Biome (via `lefthook.yml`).
- **Staging/Production**:
  - Rails server deployed to Google Cloud Run (per README) or equivalent.
  - Fastly/Cloudflare handle DNS & TLS; `EDGE_*` hostnames define redirect targets.
  - Observability data flows to Tempo/Loki/Grafana (self-hosted or managed).
  - Infrastructure managed by Terraform (as referenced in README).
- **Karafka**: running `bundle exec karafka server` processes Kafka topics; `karafka-web` ties into the same process for monitoring.
- **Backups**: rely on PostgreSQL snapshots (outside repo) and MinIO/GCS backups.

---

## 11. Future Enhancements
1. Encrypt Kafka payloads and finish `EmailConsumer`.
2. Flesh out staff/admin flows (owner/customer/news/docs CRUD).
3. Implement policy checks (`am_i_user?`, `am_i_staff?`, etc.) and integrate with Pundit.
4. Publish OpenAPI via Rswag and mount `/api-docs`.
5. Add geolocation- and cookie-based personalization to `Top::*` once privacy reviewed.
6. Automate Fastly cache purges after docs/news updates.
7. Expand SMS providers and add delivery receipt handling.

---

> This DDS must evolve with the codebase. Any substantive change to controllers, models, services, or infrastructure (especially security-sensitive areas) requires a corresponding update here.
