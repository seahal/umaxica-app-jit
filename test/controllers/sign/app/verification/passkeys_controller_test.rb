# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
  end

  test "creates verification on success" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

    Sign::App::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      Sign::App::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
        Sign::App::Verification::PasskeysController.any_instance.stub(:verify_passkey!, true) do
          get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
              headers: @headers

          get new_sign_app_verification_passkey_url(ri: "jp"), headers: @headers
          assert_response :success

          post sign_app_verification_passkey_url(ri: "jp"), headers: @headers

          assert_response :redirect
          assert_redirected_to sign_app_configuration_emails_url(ri: "jp")
        end
      end
    end
  end

  test "new keeps scope and return_to in form hidden fields" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

    Sign::App::Verification::BaseController.any_instance.stub(:available_step_up_methods, [:passkey]) do
      Sign::App::Verification::PasskeysController.any_instance.stub(:prepare_passkey_challenge!, true) do
        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_app_verification_passkey_url(
          ri: "jp",
          scope: "configuration_email",
          return_to: return_to,
        ), headers: @headers

        assert_response :success
        assert_select "input[name='verification[scope]'][value='configuration_email']"
        assert_select "input[name='verification[return_to]'][value='#{return_to}']"
      end
    end
  end
end
