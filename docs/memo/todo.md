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
- Integrate with existing `UserIdentityGoogleAuth` and `UserIdentityAppleAuth` models.
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

---

Created: 2025-06-11
Updated: 2025-08-03
