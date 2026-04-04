# Priority B - Controller `any_instance.stub` Migration Plan

## Overview

Migrate tests that use `any_instance.stub` on controllers to the classical (Classical/London School)
style.

## Target file list

### Group 1: `refresh_token_expires_at` pattern (time-based)

| #   | File path                                                              | Lines          | Stubbed method              |
| --- | ---------------------------------------------------------------------- | -------------- | --------------------------- |
| 1   | `test/controllers/sign/app/edge/v0/token/refreshes_controller_test.rb` | 58, 62, 91, 95 | `:refresh_token_expires_at` |
| 2   | `test/controllers/sign/org/edge/v0/token/refreshes_controller_test.rb` | 71, 75         | `:refresh_token_expires_at` |
| 3   | `test/controllers/apex/app/web/v0/cookie_controller_test.rb`           | 71             | `:refresh_token_expires_at` |
| 4   | `test/controllers/apex/com/web/v0/cookie_controller_test.rb`           | 52             | `:refresh_token_expires_at` |
| 5   | `test/controllers/apex/org/web/v0/cookie_controller_test.rb`           | 57             | `:refresh_token_expires_at` |

**Conversion method**: use `freeze_time` or `travel_to` from TimeHelpers

### Group 2: Verification-related (step-up authentication)

| #   | File path                                                            | Lines               | Stubbed methods                                                                 |
| --- | -------------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------- |
| 1   | `test/controllers/sign/org/verification/passkeys_controller_test.rb` | 27-29               | `:available_step_up_methods`, `:prepare_passkey_challenge!`, `:verify_passkey!` |
| 2   | `test/controllers/sign/app/verification/passkeys_controller_test.rb` | 20-22, 42-43        | `:available_step_up_methods`, `:prepare_passkey_challenge!`, `:verify_passkey!` |
| 3   | `test/controllers/sign/app/verification/emails_controller_test.rb`   | 27-28, 44, 59-60... | `:available_step_up_methods`, `:send_email_otp!`, `:verify_email_otp!`          |
| 4   | `test/integration/org_verification_flow_test.rb`                     | 39, 55-57           | Same                                                                            |
| 5   | `test/integration/org_step_up_verification_enforcer_test.rb`         | 94-96               | Same                                                                            |
| 6   | `test/integration/verification_flow_test.rb`                         | 59-61               | Same                                                                            |
| 7   | `test/integration/verification_sessions_test.rb`                     | 59                  | `:verify_totp!`                                                                 |

**Conversion method**: move to service-layer dependency injection or verify through the actual
request/response flow

### Group 3: Login / authentication result cases

| #   | File path                                                              | Lines    | Stubbed methods                                      |
| --- | ---------------------------------------------------------------------- | -------- | ---------------------------------------------------- |
| 1   | `test/controllers/sign/org/in/secrets_controller_test.rb`              | 160      | `:log_in`                                            |
| 2   | `test/controllers/sign/org/in/passkeys_controller_test.rb`             | 135, 262 | Multiple methods                                     |
| 3   | `test/controllers/sign/app/in/passkeys_controller_test.rb`             | 351, 378 | `:complete_sign_in_or_start_mfa!`, `:with_challenge` |
| 4   | `test/controllers/sign/org/auth/omniauth_callbacks_controller_test.rb` | 99       | Login-related                                        |

**Conversion method**: mock the service layer or verify through database state

### Group 4: Telephone registration

| #   | File path                                                                             | Lines                   | Stubbed methods                                                             |
| --- | ------------------------------------------------------------------------------------- | ----------------------- | --------------------------------------------------------------------------- |
| 1   | `test/controllers/sign/org/configuration/telephones/registrations_controller_test.rb` | 63, 67                  | `:current_registration_telephone`, `:complete_staff_telephone_verification` |
| 2   | `test/controllers/sign/app/configuration/telephones/registrations_controller_test.rb` | 154, 178, 201, 224, 241 | Same + `set_registration_session`                                           |

**Conversion method**: replace with session operations or test the real flow

### Group 5: Individual cases

| #   | File path                                                             | Lines | Stubbed method                            |
| --- | --------------------------------------------------------------------- | ----- | ----------------------------------------- |
| 1   | `test/controllers/sign/org/configuration/passkeys_controller_test.rb` | 103   | `StaffPasskey.any_instance.stub(:valid?)` |
| 2   | `test/controllers/apex/app/web/v0/cookie_controller_test.rb`          | 141   | `:issue_access_token_from`                |

## Conversion strategy

### Strategy A: TimeHelpers for time manipulation (Group 1)

**Current code**:

```ruby
controller = Sign::App::Edge::V0::Token::RefreshesController
expires_at = Time.utc(2034, 4, 5, 6, 7, 8)

controller.any_instance.stub(:refresh_token_expires_at, expires_at) do
  post "/edge/v0/token/refresh", ...
end

assert_in_delta expires_at.to_i, response_cookie_expiry("preference_consented").to_i, 1
```

**Converted code**:

```ruby
freeze_time do
  expires_at = Time.utc(2034, 4, 5, 6, 7, 8)

  travel_to(expires_at) do
    post "/edge/v0/token/refresh", ...
  end

  assert_in_delta expires_at.to_i, response_cookie_expiry("preference_consented").to_i, 1
end
```

**Steps**:

1. Confirm that `ActiveSupport::Testing::TimeHelpers` is included in `test/test_helper.rb`
2. Wrap the entire test in `freeze_time`
3. Replace stubbed time values with `travel_to`
4. Use the same time value in assertions

### Strategy B: Move dependencies into services (Groups 2, 3)

**Current code**:

```ruby
Sign::App::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:passkey]) do
  Sign::App::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
    Sign::App::Verification::PasskeysController.any_instance.stub(:verify_passkey!, true) do
      get sign_app_verification_url(...)
    end
  end
end
```

**Converted approach (options)**:

**Option B1: Test the actual flow as an integration test**

```ruby
test "creates verification on success via real flow" do
  return_to = Base64.urlsafe_encode64(sign_app_configuration_passkeys_path(ri: "jp"))

  # Run the real step-up authentication flow
  user = users_with_passkey(:one) # Prepare a fixture with passkey data

  get sign_app_verification_url(scope: "configuration_passkey", return_to: return_to), ...

  follow_redirect!
  assert_response :success

  post sign_app_verification_passkey_url, params: {
    credential: valid_passkey_credential_for(user)
  }

  assert_response :redirect
  assert_redirected_to sign_app_configuration_passkeys_url(ri: "jp")
end
```

**Option B2: Mock the service layer**

```ruby
test "creates verification on success with service mock" do
  return_to = Base64.urlsafe_encode64(sign_app_configuration_passkeys_path(ri: "jp"))

  # Mock the service method
  mock_service = Minitest::Mock.new
  mock_service.expect :call, true, [User, String, Hash]

  Sign::App::PasskeyVerificationService.stub :verify!, mock_service do
    get sign_app_verification_url(scope: "configuration_passkey", return_to: return_to), ...

    get new_sign_app_verification_passkey_url(ri: "jp"), ...

    post sign_app_verification_passkey_url(ri: "jp"), ...
  end

  mock_service.verify
end
```

### Strategy C: Database-backed tests (Groups 3, 4)

**Pattern**: Replace stubs that simulate authentication results

**Current code**:

```ruby
Sign::Org::In::SecretsController.any_instance.stub(:log_in, { status: :unknown }) do
  post sign_org_in_secret_url(ri: "jp"), ...
end
```

**Converted code**:

```ruby
test "create renders invalid when login fails" do
  # Use invalid authentication data
  post sign_org_in_secret_url(ri: "jp"),
       params: { secret_login_form: {
         identifier: @staff.public_id,
         secret_value: "invalid-secret"
       } }

  assert_response :unprocessable_content
  assert_includes response.body, I18n.t("sign.org.authentication.secret.create.invalid")
end
```

### Strategy D: Session operation replacement (Group 4)

**Current code**:

```ruby
def set_registration_session(id)
  Sign::App::Configuration::Telephones::RegistrationsController.any_instance.stub(
    :current_registration_telephone,
    UserTelephone.find(id),
  ) do
    yield if block_given?
  end
end
```

**Converted code**:

```ruby
def set_registration_session(telephone)
  # Store through the actual session
  post sign_app_configuration_telephones_registrations_path(ri: "jp"),
       params: { user_telephone: { raw_number: telephone.raw_number } }
  assert_response :redirect # Confirmation code sent
end
```

## Implementation steps

### Phase 1: Foundation work

- [ ] Confirm `ActiveSupport::Testing::TimeHelpers` is included in `test/test_helper.rb`

### Phase 2: TimeHelpers conversion

- [ ] Migrate Group 1 tests to `freeze_time` / `travel_to`
- [ ] Remove `any_instance.stub` usage from refresh-related controller tests

### Phase 3: Verification flow cleanup

- [ ] Replace Group 2 stubs with service injection or real request flows
- [ ] Verify step-up authentication behavior through integration tests

### Phase 4: Login result cleanup

- [ ] Remove `log_in` and similar controller stubs from login tests
- [ ] Cover failure cases with real invalid input or service mocks

### Phase 5: Registration flow cleanup

- [ ] Replace registration session stubs with real session setup
- [ ] Keep helper methods focused on request setup only

### Phase 6: Group 3 (login/authentication)

- [ ] SecretsController
- [ ] PasskeysController (app and org)
- [ ] OmniauthCallbacksController

**Review points**:

- Is extracting the service layer appropriate?
- Are error cases covered?

### Phase 7: Overall consistency and CI verification

- [ ] Confirm that all tests pass
- [ ] Confirm that test execution time has not degraded
- [ ] Review the coverage report

## Risks and mitigations

| Risk                                          | Impact | Mitigation                                                                      |
| --------------------------------------------- | ------ | ------------------------------------------------------------------------------- |
| Time zone issues when using TimeHelpers       | Medium | Use UTC explicitly and avoid unnecessary JST conversions                        |
| Design changes required by service extraction | High   | Create a separate task for extraction planning; only replace stubs in this task |
| Test instability from real WebAuthn calls     | High   | Keep WebAuthn mocked and remove only the controller stubs                       |
| Increased complexity in session tests         | Medium | Add helper methods and keep the test flow readable                              |
| Longer test execution time                    | Medium | Confirm whether the increase from real DB operations is acceptable              |

## Success criteria

1. All `any_instance.stub` calls are removed
2. Existing test coverage is preserved
3. Test execution time does not worsen by more than 20%
4. All CI checks pass

## Notes

- **Never do**: `send(:method_name)` calls against controller private methods
- **Patterns to avoid**: complex branching inside tests
- **Preferred pattern**: verify through the actual request/response cycle
