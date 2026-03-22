# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

# Integration tests for Org verification flow
#
# These tests verify:
# - Org staff verification flow works similarly to App
# - Email OTP is NOT available for Org (passkey only)
# - High-risk operations require verification
class OrgVerificationFlowTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_passkeys, :staff_passkey_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NOTHING,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "ovf#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = as_staff_headers(@staff, host: @host)
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "org verification show page does not display email option" do
    # Create passkey for staff to ensure link is rendered
    StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id",
      public_key: "test_public_key",
      sign_count: 0,
    )

    Sign::Org::VerificationController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      get sign_org_verification_url(ri: "jp"), headers: @headers

      assert_response :success

      assert response.body.include?("/verification/passkey/new") || response.body.include?("passkey")

      # Should NOT have email link (no emails route for org)
      assert_select "a[href*='email']", count: 0
      assert_select "a[href*='verification/totp']", count: 0
    end
  end

  test "org can verify with passkey" do
    return_to = Base64.urlsafe_encode64(sign_org_configuration_passkeys_path(ri: "jp"))

    Sign::Org::VerificationController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      Sign::Org::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
        Sign::Org::Verification::PasskeysController.any_instance.stub(:verify_passkey!, true) do
          get sign_org_verification_url(scope: "configuration_passkey", return_to: return_to, ri: "jp"),
              headers: @headers

          post sign_org_verification_passkey_url(ri: "jp"), headers: @headers

          assert_response :redirect
          # Redirects to return_to decoded value
          assert_redirected_to sign_org_configuration_passkeys_url(ri: "jp")
        end
      end
    end
  end
end
