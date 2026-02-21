# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Org::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @headers = as_staff_headers(@staff, host: @host)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "org_verify_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
  end

  test "creates verification on success" do
    return_to = Base64.urlsafe_encode64(sign_org_configuration_passkeys_path(ri: "jp"))

    Sign::Org::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      Sign::Org::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
        Sign::Org::Verification::PasskeysController.any_instance.stub(:verify_passkey!, true) do
          get sign_org_verification_url(scope: "configuration_passkey", return_to: return_to, ri: "jp"),
              headers: @headers

          get new_sign_org_verification_passkey_url(ri: "jp"), headers: @headers
          assert_response :success

          post sign_org_verification_passkey_url(ri: "jp"), headers: @headers

          assert_response :redirect
          assert_redirected_to sign_org_configuration_passkeys_url(ri: "jp")

          @token.reload
          assert_not_nil @token.last_step_up_at
          assert_equal "configuration_passkey", @token.last_step_up_scope
          assert_nil session[:reauth]
        end
      end
    end
  end
end
