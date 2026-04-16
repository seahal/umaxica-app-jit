# Refactor Plan: i18n Hardcoded Messages, Test Naming, and Missing Tests

## Scope

This plan covers three items:

1. **i18n hardcoded Japanese messages** — move hardcoded `RECOVERY_IDENTITY_REQUIRED_MESSAGE`
   strings into locale YAML files and use `I18n.t()` calls.
2. **Test file naming inconsistencies** — rename misaligned test files to mirror their corresponding
   model files.
3. **Missing test stubs** — add skeleton test files for models that lack tests.

Item 2 from the original audit (removing `# what is this?` comments in `user.rb`) is deferred and
not included.

Sorbet `# typed:` upgrades are explicitly excluded per the owner's decision.

---

## 1. i18n: Replace Hardcoded Japanese Messages with `I18n.t()` Calls

### Problem

`User::RECOVERY_IDENTITY_REQUIRED_MESSAGE` and `Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE`
contain inline Japanese strings. The project i18n rule requires all translation text to be defined
in YAML locale files. `User` has already been partially converted (uses `I18n.t()` on line 57), but
`Customer` still has the hardcoded string. The locale key
`activerecord.errors.messages.recovery_identity_required` exists in `ja.yml` but is missing from
`en.yml`.

### Files to Change

| File                        | Current                                                           | Target                                                                                                                                                                                          |
| --------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app/models/customer.rb:55` | `RECOVERY_IDENTITY_REQUIRED_MESSAGE = "パスキー/シークレットを…"` | `RECOVERY_IDENTITY_REQUIRED_MESSAGE = I18n.t("activerecord.errors.messages.recovery_identity_required")`                                                                                        |
| `config/locales/en.yml`     | Key missing                                                       | Add `recovery_identity_required: "To register a passkey or secret, first register (verify) at least one email address or phone number."` after `identity_audit_event_format_invalid` (line 778) |
| `config/locales/ja.yml:101` | Already present                                                   | No change needed                                                                                                                                                                                |

### Notes

- `app/models/user.rb:57` was already converted to `I18n.t(...)` in a prior edit. No change needed
  there.
- All call sites (`user_secret.rb`, `user_passkey.rb`, `customer_secret.rb`, `customer_passkey.rb`,
  controller render calls, and test assertions) reference the constant
  (`User::RECOVERY_IDENTITY_REQUIRED_MESSAGE` / `Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE`).
  Since the constant value is resolved at class load time, these references continue to work without
  change.
- However, `I18n.t()` called at class body level evaluates once during class loading. If the locale
  is not set or differs at load time, the message may resolve incorrectly. If this becomes a
  concern, an alternative is to make the constant a method:
  ```ruby
  def self.recovery_identity_required_message
    I18n.t("activerecord.errors.messages.recovery_identity_required")
  end
  ```
  This is a judgment call. The simplest correct fix matching the existing `User` pattern is to use
  `I18n.t()` at constant definition, identical to what `user.rb` already does.

### Verification

```bash
bundle exec rails test
bundle exec rubocop app/models/user.rb app/models/customer.rb
```

Confirm `I18n.t("activerecord.errors.messages.recovery_identity_required")` resolves in both `ja`
and `en` locales.

---

## 2. Test File Naming Inconsistencies

### Problem

Some test file names do not mirror their corresponding model file names, violating the convention
that test files match the model name exactly.

### Inconsistencies Found

| Model file                                   | Current test file                                                                                                                                    | Expected test file                      |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| `app/models/token_record.rb` (`TokenRecord`) | `test/models/tokens_record_test.rb` (class `TokenRecordTest`)                                                                                        | `test/models/token_record_test.rb`      |
| `app/models/guest_record.rb` (`GuestRecord`) | Two test files exist: `test/models/guest_record_test.rb` (class `GuestRecordTest`) and `test/models/guests_record_test.rb` (class `GuestRecordTest`) | `test/models/guest_record_test.rb` only |

### Steps

#### 2a. Fix `tokens_record_test.rb` → `token_record_test.rb`

1. `git mv test/models/tokens_record_test.rb test/models/token_record_test.rb`
2. No class rename needed — the class inside is already `TokenRecordTest`.

#### 2b. Merge/Remove duplicate `guests_record_test.rb`

1. Compare the two files. `guest_record_test.rb` has 14 lines with basic tests;
   `guests_record_test.rb` has 50 lines with additional tests.
2. The tests in `guests_record_test.rb` should be merged into `guest_record_test.rb`, avoiding
   duplication.
3. After merging, delete `guests_record_test.rb`.
4. Specific tests to port from `guests_record_test.rb` into `guest_record_test.rb`:
   - `"should be abstract class"` (already exists in `guest_record_test.rb` — keep one)
   - `"should inherit from ApplicationRecord"` (already exists — keep one)
   - `"should connect to guest database"` (similar to existing — deduplicate)
   - `"should have correct database configuration"`
   - `"should connect to correct writing database"`
   - `"should not be instantiable as abstract class"`
   - `"should have database connection methods"`
   - `"should inherit ActiveRecord methods"`
5. Rewrite `guest_record_test.rb` to include all unique, meaningful tests from both files in one
   clean file.

### Verification

```bash
bundle exec rails test test/models/token_record_test.rb test/models/guest_record_test.rb
bundle exec rubocop test/models/token_record_test.rb test/models/guest_record_test.rb
```

---

## 3. Missing Test Stubs

### Problem

The following model/concern files have no corresponding test files:

- `app/models/concerns/oidc_authorization_code.rb` — a 133-line concern with PKCE verification, code
  issue/consume/revoke logic, and validations.
- `app/models/principal_record.rb` — a 10-line abstract base class connecting to the principal
  database.

### Steps

#### 3a. Create `test/models/oidc_authorization_code_test.rb`

This concern is included by `UserAuthorizationCode` and `StaffAuthorizationCode`. Since it's a
concern, test it through one of its including models.

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

class OidcAuthorizationCodeTest < ActiveSupport::TestCase
  # Test through UserAuthorizationCode which includes the concern.
  # Add tests for:
  # - expired? returns true when varnishable_at is in the past
  # - expired? returns false when varnishable_at is in the future
  # - consumed? returns true when consumed_at is present
  # - revoked? returns true when revoked_at is present
  # - usable? returns true when not expired, consumed, or revoked
  # - consume! raises when already consumed
  # - consume! raises when revoked
  # - consume! raises when expired
  # - revoke! sets revoked_at
  # - verify_pkce returns true for correct verifier
  # - verify_pkce returns false for incorrect verifier
  # - verify_pkce returns false for blank verifier
  # - validations: code, client_id, redirect_uri, code_challenge, code_challenge_method, varnishable_at
end
```

#### 3b. Create `test/models/principal_record_test.rb`

```ruby
# typed: false
# frozen_string_literal: true

require "test_helper"

class PrincipalRecordTest < ActiveSupport::TestCase
  test "is abstract class" do
    assert_predicate PrincipalRecord, :abstract_class?
  end

  test "inherits from ApplicationRecord" do
    assert_operator PrincipalRecord, :<, ApplicationRecord
  end
end
```

### Verification

```bash
bundle exec rails test test/models/oidc_authorization_code_test.rb test/models/principal_record_test.rb
bundle exec rubocop test/models/oidc_authorization_code_test.rb test/models/principal_record_test.rb
```

---

## Execution Order

1. Item 1 (i18n) — lowest risk, isolated change.
2. Item 2 (test naming) — file renames and merge require care.
3. Item 3 (missing test stubs) — additive only, no existing code changes.

## Final Validation

After all items are complete:

```bash
bundle exec rubocop
bundle exec erb_lint .
vp check
vp test
bundle exec rails test
```

Report any blocked or skipped commands explicitly.
