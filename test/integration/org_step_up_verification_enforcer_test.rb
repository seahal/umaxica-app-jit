# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class OrgStepUpVerificationEnforcerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_activity_events, :staff_activity_levels,
           :staff_token_statuses, :staff_token_kinds

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NOTHING,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
      public_id: "stepup_org_#{SecureRandom.hex(4)}",
    )
    @headers = as_staff_headers(@staff, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "GET protected endpoint redirects to setup when configured methods are zero" do
    StepUp::ConfiguredMethods.stub(:call, []) do
      StepUp::AvailableMethods.stub(:call, []) do
        get sign_org_configuration_withdrawal_url(ri: "jp"), headers: @headers
      end
    end

    assert_response :redirect
    uri = URI.parse(response.location)
    query = Rack::Utils.parse_query(uri.query)

    assert_equal "/verification/setup/new", uri.path
    assert_predicate query["rd"], :present?
  end

  test "GET protected endpoint redirects to verification when configured is non-zero but usable is zero" do
    StepUp::ConfiguredMethods.stub(:call, [:passkey]) do
      StepUp::AvailableMethods.stub(:call, []) do
        get sign_org_configuration_withdrawal_url(ri: "jp"), headers: @headers
      end
    end

    assert_response :redirect
    uri = URI.parse(response.location)
    query = Rack::Utils.parse_query(uri.query)

    assert_equal "/verification", uri.path
    assert_predicate query["rd"], :present?
  end

  test "GET protected endpoint redirects to verification when usable methods exist" do
    StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "stepup_staff_passkey_#{SecureRandom.hex(4)}",
      external_id: SecureRandom.uuid,
      public_key: "public_key",
      sign_count: 0,
      name: "stepup passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    get sign_org_configuration_withdrawal_url(ri: "jp"), headers: @headers

    assert_response :redirect
    uri = URI.parse(response.location)

    assert_equal "/verification", uri.path
  end

  test "POST protected endpoint returns 401 plain when step-up is missing and usable methods exist" do
    StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "stepup_staff_passkey_post_#{SecureRandom.hex(4)}",
      external_id: SecureRandom.uuid,
      public_key: "public_key",
      sign_count: 0,
      name: "stepup passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    post options_sign_org_configuration_passkeys_url(ri: "jp"), headers: @headers

    assert_response :unauthorized
    assert_equal "Re-authentication required", response.body
  end

  test "successful verification enables protected POST and records audit" do
    return_to = Base64.urlsafe_encode64(sign_org_configuration_passkeys_path(ri: "jp"))

    Sign::Org::VerificationsController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      Sign::Org::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
        Sign::Org::Verification::PasskeysController.any_instance.stub(:verify_passkey!, true) do
          get sign_org_verification_url(scope: "configuration_passkey", return_to: return_to, ri: "jp"),
              headers: @headers

          assert_response :success

          post sign_org_verification_passkey_url(ri: "jp"), headers: @headers
        end
      end
    end

    assert_response :redirect
    assert_redirected_to sign_org_configuration_passkeys_url(ri: "jp")
    assert response_has_cookie?(StaffVerification.cookie_name)

    assert StaffVerification.active.exists?(staff_token_id: @token.id)
    assert StaffActivity.exists?(
      actor_type: "Staff",
      actor_id: @staff.id,
      event_id: StaffActivityEvent::STEP_UP_VERIFIED,
      subject_type: "Staff",
      subject_id: @staff.id,
    )

    post options_sign_org_configuration_passkeys_url(ri: "jp"), headers: @headers

    assert_not_equal 401, response.status
  end
end
