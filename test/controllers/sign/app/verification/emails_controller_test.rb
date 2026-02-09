# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
    UserEmail.create!(
      user: @user,
      address: "verified-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      otp_private_key: "otp_private_key",
      otp_counter: "0",
    )
  end

  test "new sends otp and redirects to edit" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))

    Sign::App::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:email_otp]) do
      Sign::App::Verification::BaseController.any_instance.stub(:send_email_otp!, true) do
        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_app_verification_email_url(ri: "jp"), headers: @headers
        assert_response :redirect

        assert_match %r{/verification/emails/.+/edit}, response.location
      end
    end
  end

  test "update verifies otp and redirects to return_to" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_path(ri: "jp"))

    Sign::App::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:email_otp]) do
      Sign::App::Verification::BaseController.any_instance.stub(:send_email_otp!, true) do
        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_app_verification_email_url(ri: "jp"), headers: @headers
        nonce = response.location[%r{/verification/emails/([^/]+)/edit}, 1]

        Sign::App::Verification::BaseController.any_instance.stub(:verify_email_otp!, true) do
          patch sign_app_verification_email_url(nonce, ri: "jp"),
                params: { verification: { code: "123456" } },
                headers: @headers

          assert_response :redirect
          assert_redirected_to sign_app_configuration_url(ri: "jp")
        end
      end
    end
  end
end
