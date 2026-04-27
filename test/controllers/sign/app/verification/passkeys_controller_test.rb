# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::Verification::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("ID_SERVICE_URL", "id.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
    @token = UserToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
  end

  test "creates verification on success" do
    return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

    StepUp::AvailableMethods.stub(:call, [:passkey]) do
      WebAuthn::Credential.stub(:options_for_get, OpenStruct.new(id: "test")) do
        WebAuthn::Credential.stub(:from_get, OpenStruct.new(id: "test", verify: true, sign_count: 1)) do
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

    StepUp::AvailableMethods.stub(:call, [:passkey]) do
      WebAuthn::Credential.stub(:options_for_get, OpenStruct.new(id: "test")) do
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
