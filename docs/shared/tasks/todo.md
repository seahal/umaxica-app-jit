# Codebase Issue List - Items Requiring Fixes

## 🚨 Highest-Priority Issues

### 1. Hard-coded API key (rack_attack.rb:6)
- Problem: The string `"secret-string"` is hard-coded, allowing anyone to bypass rate limiting.
- File: config/initializers/rack_attack.rb
- Fix: Replace with environment variables or encrypted credentials.

### 2. Production database configuration incomplete (database.yml:317-323)
- Problem: "FIXME" comments remain, preventing production from connecting to the database.
- File: config/database.yml
- Fix: Fill in the production database configuration with the correct connection details.

### 3. Authentication system is not working
- Problem: The `logged_in?` method always returns `false`, blocking user authentication.
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
- Fix: Introduce appropriate SSL settings and consider secure cookies in development.

### 6. CSP allows unsafe-inline (content_security_policy.rb:15-16)
- Problem: `:unsafe_inline` is permitted for scripts and styles, opening XSS risk.
- Fix: Remove `unsafe-inline` and use nonce-based CSP.

### 7. Active Record encryption keys in environment variables (development.rb:141-143)
- Problem: Keys might leak through logs or the process list.
- Fix: Move the keys into Rails encrypted credentials.

### 8. Missing strong parameter filtering
- Problem: Controllers are missing strong parameter whitelists.
- Fix: Use the `permit` method to whitelist parameters.

## 🏗 Code Quality and Architecture Issues

### 9. Extremely low test coverage
- Problem: Only 95 tests across more than 17,500 files (~0.5%).
- Fix: Expand coverage, concentrating on security-sensitive modules first.

### 10. WebAuthn implementation incomplete (web_authn.rb)
- Problem: The WebAuthn concern is empty.
- Fix: Complete the WebAuthn implementation or remove unused code.

### 11. Session management concerns (memorize.rb)
- Problem: Custom Redis-based session management risks key collisions.
- Fix: Add proper namespacing and validation for session keys.

### 12. Multi-database architecture is overly complex
- Problem: More than ten separate databases with intricate replica configuration.
- Fix: Consolidate databases where possible or improve configuration management.

## 📋 Recommended Order of Work

1. **Move the API key into environment variables** (critical security issue).
2. **Complete the production database config** (prevents deployment failures).
3. **Implement the authentication system** (currently broken).
4. **Fix database configuration inconsistencies** (avoids replication issues).
5. **Add tests for key functionality** (strengthens quality assurance).

## 📝 Notes

- These issues directly affect production stability and security.
- The first three items impact core functionality and require immediate attention.
- Handle security fixes carefully and test thoroughly.

Created: 2025-06-11
