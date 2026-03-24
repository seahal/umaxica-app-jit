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

### Step 9: Current Attributes Construction ✅

- `Current.actor` is now the single source of truth for the authenticated resource
- `current_resource` delegates to `Current.actor` with lazy-load fallback (via `@_current_resource_resolved` flag)
- `current_user` / `current_staff` remain as convenience aliases (via `current_resource`)
- `@current_resource` instance variable fully eliminated from `Auth::Base`
- `transparent_refresh_access_token` now calls `populate_current_attributes!` (was setting `@current_resource` directly)
- `clear_auth_cookies!` resets `Current.actor` and `Current.actor_type`
- `reissue_access_token!` uses `current_resource` method instead of `@current_resource` instance variable
- `Current.reset` called per-request via `CurrentSupport#_reset_current_state` (after_action)

### Step 10: Final Verification ✅

- Full test suite: **4680 tests, 13666 assertions, 0 failures, 0 errors**
- Brakeman: **0 warnings**
- Security re-audit findings:
  - `clear_auth_cookies!` clears `Current.actor` + `Current.actor_type` ✓
  - `transparent_refresh_access_token` calls `populate_current_attributes!` ✓
  - `log_in` now calls `populate_current_attributes!` after `set_auth_cookies` ✓
  - `Current.reset` called per-request via `after_action :_reset_current_state` ✓
- N+1 queries: preference associations are `has_one`, cached after first load — no N+1 risk
- `reissue_access_token!` updates `Current.preference` immediately after re-encoding JWT ✓
- Guest/bearer flows use `Current::Preference::NULL` singleton via null object pattern ✓

---

## Test Performance Investigation Notes (2026-03-22)

### Scope investigated

- `test/policies/com_timeline_policy_test.rb`
- `test/models/org_preference_status_test.rb`
- `test/models/org_preference_activity_level_test.rb`
- `test/models/app_preference_activity_event_test.rb`
- `test/controllers/sign/org/verification_controller_test.rb`
- `test/controllers/core/org/healths_controller_test.rb`

### What the measurements suggest

- The slowest results from the full `bin/rails test --verbose` run were a mix of:
  - genuine expensive test paths
  - tests that were mostly paying for shared full-suite overhead
- Isolated reruns showed that several of the flagged tests were not intrinsically slow by
  themselves, which strongly suggests contention / bootstrap cost during the full parallel run.

### Confirmed causes

#### Shared test harness overhead

- `test/test_helper.rb` enables parallel workers and loads `fixtures :all` for
  `ActiveSupport::TestCase`.
- That means even tiny tests can look slow when they happen to pay worker/bootstrap/fixture cost in
  the full suite.
- This is the main explanation for `ComTimelinePolicyTest`, whose own logic is effectively trivial.

#### Fixed-ID bootstrap contention

- `OrgPreferenceStatus`, `OrgPreferenceActivityLevel`, and `AppPreferenceActivityEvent` all use the
  same fixed-ID `ensure_defaults!` pattern.
- Those tests either call `ensure_defaults!` directly or query tables that are also initialized by
  bootstrap code and other tests.
- During the full parallel suite, this likely becomes connection / table contention on shared
  databases such as `preference` and `activity`.

#### Multi-DB setup inside verification tests

- `Sign::Org::VerificationControllerTest` creates a `StaffToken` and a `StaffPasskey` in setup.
- That crosses at least the token DB and operator DB and also runs through authentication /
  verification before-actions.
- This makes it materially heavier than a simple request test and more sensitive to suite-wide DB
  contention.

#### Real dependency sweep in health tests

- `Core::Org::HealthsControllerTest` exercises the `Health` concern.
- That concern loops over many record classes and both `writing` / `reading` roles, issuing DB
  connectivity checks repeatedly.
- This path remained slower even in isolated runs, so this is a real hot spot, not only a harness
  artifact.

### Improvement priorities

#### Priority 1 — Reduce unnecessary global fixture cost

- Revisit `fixtures :all` usage in `test/test_helper.rb`.
- Goal: stop tiny policy/model tests from paying for unrelated global fixture loading.
- Expected impact: broad suite-wide speedup, especially for many otherwise-cheap tests.

#### Priority 2 — Stabilize fixed-ID bootstrap behavior

- Revisit how fixed-ID defaults are prepared for tests using `ensure_defaults!`.
- Goal: reduce repeated read/write work and contention on shared `preference` / `activity`
  databases.
- Expected impact: targeted improvement for the preference/activity master-data style tests and
  lower variance in parallel runs.

#### Priority 3 — Slim down verification controller setup

- Audit whether `Sign::Org::VerificationControllerTest` can rely more on lightweight helpers or
  pre-created state instead of creating fresh token/passkey records in every setup.
- Goal: cut repeated cross-database setup and reduce integration-test overhead.
- Expected impact: medium, concentrated in auth / verification test areas.

#### Priority 4 — Decide how much of health dependency probing belongs in request tests

- Review whether `Core::Org::HealthsControllerTest` should always exercise the full database sweep
  in controller/request coverage, or whether some of that logic should be covered separately with
  more focused tests.
- Goal: keep confidence in health behavior while reducing repeated expensive dependency checks.
- Expected impact: meaningful for this file specifically; limited suite-wide compared with Priority
  1 and 2.

### Recommended order if we actually optimize

1. Tackle global fixture scope first.
2. Then fix repeated fixed-ID bootstrap / `ensure_defaults!` contention.
3. Then simplify verification controller test setup.
4. Finally, redesign health-check test coverage if needed.
