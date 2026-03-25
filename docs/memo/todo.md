# Codebase Issue List - Items Requiring Fixes

## 🚨 Highest-Priority Issues

### 1. Hard-coded API key (rack_attack.rb:6)

- Problem: The value `"secret-string"` is hard-coded, allowing anyone to bypass rate limiting.
- File: config/initializers/rack_attack.rb
- Fix: Use environment variables or encrypted credentials.

### 2. Production database configuration incomplete (database.yml:317-323)

- Problem: "FIXME" comments remain; production cannot connect to the database.
- File: config/database.yml
- Fix: Supply the correct connection details for production.

### 3. Authentication system not functioning

- Problem: The `logged_in?` method always returns `false`, preventing authentication.
- Files: app/controllers/concerns/authentication.rb, authorization.rb
- Fix: Implement proper authentication logic.

## 🔒 Security Concerns

### 4. Database configuration inconsistencies (database.yml)

- Problems:
  - Incorrect environment variable references (lines 100, 113, 140).
  - Wrong migration path (line 140: `specialitys_migrate` → `specialities_migrate`).
- Fix: Correct the environment variables and migration path.

### 5. Insecure cookie settings in development

- Problem: `secure: Rails.env.production? ? true : false` leaves cookies vulnerable on HTTP.
- Fix: Consider enforcing secure cookies with suitable SSL settings even during development.

### 6. CSP allows unsafe-inline (content_security_policy.rb:15-16)

- Problem: `:unsafe_inline` is enabled for scripts and styles, creating XSS risk.
- Fix: Remove `unsafe-inline` and adopt nonce-based CSP.

### 7. Active Record encryption keys in environment variables (development.rb:141-143)

- Problem: Keys may leak through logs or process listings.
- Fix: Store the keys inside Rails encrypted credentials.

### 8. Missing strong parameter filtering

- Problem: Controllers lack strong parameter whitelisting.
- Fix: Apply the `permit` method to enforce safe parameters.

## 🏗 Code Quality and Architecture Issues

### 9. Extremely low test coverage

- Problem: Only 95 tests for 17,500+ files (~0.5%).
- Fix: Add comprehensive coverage, starting with security-critical components.

### 10. WebAuthn implementation incomplete (web_authn.rb)

- Problem: The WebAuthn concern is empty.
- Fix: Complete the WebAuthn implementation or remove unused code.

### 11. Session management concerns (memorize.rb)

- Problem: Custom Redis session management risks key collisions.
- Fix: Introduce proper namespacing and validation for session keys.

### 12. Overly complex multi-database architecture

- Problem: More than 10 databases with complicated replica settings.
- Fix: Consider consolidation or improved configuration management.

## 📋 Recommended Order of Work

1. **Move the API key into environment variables** (critical security issue).
2. **Complete the production database config** (prevents deployment failures).
3. **Implement the authentication system** (currently non-functional).
4. **Fix database configuration inconsistencies** (avoids replication issues).
5. **Add tests for critical features** (improves quality assurance).

## 📝 Notes

- These issues directly affect stability and security in production.
- The first three items block core application functionality and require immediate attention.
- Handle security fixes carefully and ensure thorough testing.

## 🎯 Implementation Plan Starting 2025-08-04

### 1. OmniAuth setup – Google/Apple OAuth integration

- Configure Google OAuth and callbacks.
- Configure Apple OAuth and callbacks.
- Integrate with existing `UserIdentitySocialGoogle` and `UserIdentitySocialApple` models.
- Complete the OAuth authentication flow.

### 2. Recovery page completion

- Implement the recovery flow.
- Integrate with `UserRecoveryCode` and `StaffRecoveryCode`.
- Add recovery-code generation and validation.
- Finalise the user-facing recovery UI.

### 3. Finish the Passkey implementation

- Complete the WebAuthn authentication system.
- Finalise `UserIdentityPasskey` and `StaffIdentityPasskey` models.
- Finish passkey registration and authentication flows.
- Integrate multi-factor authentication.

### 4. Connect `JwtOccurrence` to runtime JWT anomaly collection

- Status: partial
- Done: auth/preference JWT verification failures now normalize anomaly codes and emit
  `Rails.event`, and a direct-save subscriber can persist lightweight JWT anomaly events.
- Constraint: never store raw JWTs; keep only safe metadata like `kid`, `alg`, `typ`, `iss`, `jti`,
  request host, IP, and user agent.
- Deferred: add HMAC-based request identifiers before linking JWT anomaly events to
  `UserOccurrence`, `StaffOccurrence`, `IpOccurrence`, or other existing occurrence families.
- Deferred: design deduplication/rate-limiting for anomaly event persistence so repeated malformed
  requests do not generate unbounded write amplification.
- Deferred: define retention/cleanup policy for append-only JWT anomaly event records.
- Deferred: backfill or enrich JWT anomaly events with normalized actor/session/request linkage once
  the broader occurrence correlation strategy is finalized.

### 5. Fix Apex OIDC flow and related tests

- Status: deferred as of 2026-03-25
- Scope:
  - `app/controllers/concerns/oidc/sso_initiator.rb`
  - `app/controllers/concerns/oidc/callback.rb`
  - `app/controllers/apex/app/application_controller.rb`
  - `app/controllers/apex/com/configurations_controller.rb`
  - `app/controllers/apex/org/configurations_controller.rb`
  - `app/config/oidc/client_registry.rb`
  - `test/controllers/concerns/oidc/sso_initiator_test.rb`
  - `test/controllers/concerns/oidc/callback_test.rb`
- Observed issues from `bundle exec rails test`:
  - Unauthenticated Apex configuration requests redirect to `.../configuration?ri=jp` before OIDC
    starts, so expected `/authorize` redirects and session state storage do not happen.
  - `Oidc::ClientRegistry.register` is referenced by tests but not implemented by the current
    registry API.
  - Callback tests expect redirects/cookies that do not match the current callback routing and
    execution path.
  - `ActionController::InvalidAuthenticityToken` usage now raises a Rails deprecation; migrate to
    the non-deprecated cross-origin exception path.
  - Logged-in test setup assumes `User#token_version`, which is not available on the current user
    model interface.
- Likely work:
  - Decide whether Apex configuration pages must be auth-gated before region normalization.
  - Reorder or conditionalize `set_region` / access policy enforcement so OIDC can initiate.
  - Align callback behavior, registry API, and tests around the actual RP/client registration flow.
  - Replace deprecated exception expectations in callback tests and/or implementation.

### 6. Fix Sign Org passkey challenge flow and related tests

- Status: deferred as of 2026-03-25
- Scope:
  - `app/controllers/sign/org/in/challenge/passkeys_controller.rb`
  - related sign/org views, forms, and translations
  - `test/controllers/sign/org/in/challenge/passkeys_controller_test.rb`
- Observed issues from `bundle exec rails test`:
  - Many passkey challenge requests return `422 Unprocessable Content` where tests expect
    redirects or success.
  - Translation key `ja.sign.org.in.mfa.session_expired` is missing.
  - The current controller/test contract is not stable enough to resolve by test-only changes.
- Likely work:
  - Inspect why challenge routes are rejected with `422` before the expected flow executes
    (CSRF, parameter shape, session prerequisites, or form contract).
  - Add/fix the missing MFA session-expired translation.
  - Reconcile controller responses with the intended UX for invalid challenge, challenge expiry,
    turnstile failure, and successful MFA completion.

---

Created: 2025-06-11 Updated: 2026-03-25
