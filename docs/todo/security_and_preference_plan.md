# Security Hardening & Preference System Plan

Created: 2026-03-21

## Current State

### Completed Changes (this session)

- **C2**: Org MFA challenge infrastructure (passkey-only) - routes, controllers, views,
  `mfa_required_for?` extended to Staff
- **H1**: Timing side-channel in `RefreshTokenService` fixed - now uses
  `refresh_token_digest_matches?` (SHA3-384 + `secure_compare`)
- **H3**: Turnstile added to email sign-up (`Sign::App::Up::EmailsController`)
- **H4**: Rack::Attack not needed - CDN + Rails `rate_limit` will be used instead
- **M1**: Secure cookie flags now respect `request.ssl?` and `FORCE_SECURE_COOKIES` env var
- **M2**: `auth_failed` events wired to `Sign::Risk::Emitter` in app/org secrets + email OTP
  controllers
- **M3**: ~~Refresh token cookie encrypted (`cookies.encrypted`)~~ — Reverted: refresh tokens are
  already hash-verified (SHA3-384 digest in DB), encryption is unnecessary overhead
- **M4**: Cross-subdomain cookie scope documented as accepted risk
- **M5**: `trusted_origins` now environment-variable-based (`SIGN_APP_TRUSTED_ORIGINS`,
  `SIGN_ORG_TRUSTED_ORIGINS`)
- **L1**: Stealth Turnstile added to TOTP verification
- **L2**: Risk system defaults to enabled in production, `RISK_ENFORCEMENT_DISABLED` to opt out
- **L4**: Org passkeys stub returns 404 instead of 200
- **GitHub Issue #534**: Checkpoint implementation plan

### Test Failures (21 total: 17 failures, 4 errors)

#### Caused by our changes (must fix)

| Test File                                                              | Count      | Cause                                                      |
| ---------------------------------------------------------------------- | ---------- | ---------------------------------------------------------- |
| `test/unit/core/cookie_options_test.rb`                                | 4 errors   | M1: `request.ssl?` added, test mock needs `request` object |
| `test/controllers/sign/app/edge/v0/token/refreshes_controller_test.rb` | 2 failures | M3: refresh cookie now encrypted, test expects plain value |
| `test/controllers/sign/org/passkeys_controller_test.rb:61,73`          | 2 failures | L4: `head :ok` -> `head :not_found`                        |
| `test/controllers/sign/org/in/passkeys_controller_test.rb:281`         | 1 failure  | C2: MFA now enforced for staff with `multi_factor_enabled` |
| `test/controllers/sign/org/in/secrets_controller_test.rb:174`          | 1 failure  | C2: `complete_sign_in_or_start_mfa!` change                |
| `test/controllers/sign/app/up/emails_controller_test.rb:319`           | 1 failure  | H3: Turnstile now required on email sign-up                |
| `test/integration/authentication_flow_test.rb`                         | 4 failures | M3: refresh cookie encrypted                               |

#### Likely pre-existing (verify)

| Test File                                                         | Count      | Notes                         |
| ----------------------------------------------------------------- | ---------- | ----------------------------- |
| `test/controllers/sign/app/configuration/outs_controller_test.rb` | 1 failure  | Check git log                 |
| `test/controllers/sign/app/configurations_controller_test.rb`     | 3 failures | Check git log                 |
| `test/controllers/sign/org/configuration/outs_controller_test.rb` | 1 failure  | Check git log                 |
| `test/controllers/sign/org/passkeys_controller_test.rb:61`        | 1 failure  | May be pre-existing stub test |

---

## Roadmap (in order)

### Step 1: Fix Test Failures ✅

- All 4644 tests pass with 0 failures, 0 errors
- Reverted `cookies.encrypted` for refresh tokens (unnecessary — hash-verified)
- Fixed org secrets/passkeys for `complete_sign_in_or_start_mfa!` changes
- Fixed pre-existing i18n failures (English → Japanese)

### Step 2: Sign In/Up Security Re-audit ✅

- Risk system migrated from Redis to PostgreSQL (`UserOccurrence`/`StaffOccurrence`)
- Risk events emitted from all auth failure paths (passkey, TOTP, OAuth, MFA)
- Turnstile stealth added to MFA passkey controllers (app + org)
- `auth/base.rb` emit calls now use correct `user_id:`/`staff_id:` via `risk_actor_payload`
- SolidQueue recurring task for occurrence cleanup (every 15 min)
- Org secrets controller fixed: `user_id:` → `staff_id:` for staff risk events

### Step 3: Auth Cookie Implementation Review ✅

- **Secure flag**: Unified all callers to delegate to `Core::CookieOptions.resolve_secure` —
  respects `Rails.env.production?`, `FORCE_SECURE_COOKIES`, and `request.ssl?`
- **DBSC cookie**: Added `clear_dbsc_cookie!` to login pre-cleanup (was missing)
- **Logout test**: Added cookie clearing verification tests for app + org
- **Preference cookies**: Confirmed intentionally NOT cleared on auth logout (app/org/com
  preferences persist, used for access token construction)
- **Cross-subdomain scope**: Confirmed accepted risk (M4), httponly mitigates XSS
- **No issues found**: httponly, SameSite:Lax, `__Secure-` prefix, DBSC binding, device_id
  encryption all correct

### Step 4: Preference JWT/Token Implementation

- Add `prf` claim to `Auth::TokenClaims.build` with preference snapshot
- Create `Current::Preference` value object (cookie consent + JWT preference data)
- Implement `Current::Preference.from_jwt(prf_claim)` and `.with_cookie(...)`
- Implement `reissue_access_token!` in `Auth::Base` for preference changes
- Wire `Current.preference` into request lifecycle via `before_action`
- Implement Null Object pattern for `Current.preference` (DEFAULT for guests/bearer)
- Add tests for preference JWT roundtrip

### Step 5: Preference Model Consolidation (User/Staff merge)

- Merge `AppPreference`/`OrgPreference`/`ComPreference` into `UserPreference`/`StaffPreference`
  (principal DB, 1:1)
- Implement login-time sync logic for preference data
- Consolidate `*_preference_language`, `*_preference_timezone`, etc. associations
- Remove redundant preference child-record models from preference DB
- Clean up `PreferenceRecord` base class if no longer needed
- Update all controllers referencing old preference models

### Step 6: Preference API Consolidation

- Keep preference endpoints only in `apex/com`, `apex/org`, `apex/app`
- Remove preference-related endpoints from other route files (core, sign, etc.)
- Ensure all preference reads go through `Current.preference` (not DB queries)
- Ensure all preference writes go through apex controllers + `reissue_access_token!`

### Step 7: Model & Relation Cleanup

- Delete orphaned preference models (app*preference_cookie, com_preference*_, org*preference*_,
  etc.)
- Delete unused migrations and schema references
- Remove backward-compatibility shims (PreferenceConstants, etc.)
- Run `rake uuid:pk:report` to verify no broken references
- Database consistency check

### Step 8: Dark Mode Switch & Cookie Consent (AJAX)

- Implement dark mode toggle via Stimulus controller + AJAX endpoint
- Implement cookie consent banner via Stimulus controller + AJAX endpoint
- Both should update `Current.preference` and `reissue_access_token!`
- No full page reload required

### Step 9: Current Attributes Construction

- Complete `Current` model implementation:
  - `Current.actor` -> authenticated user/staff (from JWT `sub`)
  - `Current.actor_type` -> :user / :staff (from JWT `act`)
  - `Current.session` -> session record
  - `Current.token` -> JWT payload
  - `Current.preference` -> `Current::Preference` (from JWT `prf` + cookie)
  - `Current.domain` -> :app / :org / :com (from request host)
- Replace all `@current_resource` / `current_user` / `current_staff` instance variable usage with
  `Current.actor`
- Eliminate the class of bugs where instance variables were carried across methods unexpectedly
- Ensure `Current.reset` is called per-request (ActiveSupport::CurrentAttributes handles this)
- Add tests verifying Current is properly reset between requests

### Step 10: Final Verification

- Full test suite green
- Security re-audit of all auth flows
- Performance check: no N+1 queries in preference loading
- Verify preference changes reflect within 1 request (reissue_access_token!)
- Verify guest/bearer token flows work with Null preference
