# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"
    require "base64"

    class Sign::App::Verification::EmailsControllerTest < ActionDispatch::IntegrationTest
      fixtures :users

      setup do
        @host = ENV.fetch("IDENTITY_SIGN_APP_URL", "sign.app.localhost")
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
        return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers

        get new_sign_app_verification_email_url(ri: "jp"), headers: @headers

        assert_response :redirect
        assert_match %r{/verification/emails/.+/edit}, response.location
        assert_equal "configuration_email", session[:reauth]["scope"]
        assert_predicate session[:reauth_email_otp], :present?
      end

      test "new keeps scope and return_to in form hidden fields" do
        return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers
        get new_sign_app_verification_email_url(ri: "jp"), headers: @headers

        assert_response :redirect
        assert_match %r{/verification/emails/.+/edit}, response.location
        query = Rack::Utils.parse_nested_query(URI.parse(response.location).query)

        assert_equal "configuration_email", query["scope"]
        assert_equal return_to, query["return_to"]
      end

      test "update verifies otp and redirects to return_to" do
        return_to = Base64.urlsafe_encode64(sign_app_configuration_emails_path(ri: "jp"))

        get sign_app_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
            headers: @headers
        get new_sign_app_verification_email_url(ri: "jp"), headers: @headers
        nonce = response.location[%r{/verification/emails/([^/]+)/edit}, 1]
        otp_session = session[:reauth_email_otp]
        code = ROTP::HOTP.new(otp_session["secret"]).at(otp_session["counter"])

        patch sign_app_verification_email_url(nonce, ri: "jp"),
              params: { verification: { code: code } },
              headers: @headers

        assert_response :redirect
        assert_redirected_to sign_app_configuration_emails_url(ri: "jp")
      end

      test "step up flow from configuration emails returns to original page" do
        stale_token = UserToken.create!(user_id: @user.id, created_at: 20.minutes.ago, updated_at: 20.minutes.ago)
        stale_headers = @headers.merge("X-TEST-SESSION-PUBLIC-ID" => stale_token.public_id)

        get sign_app_configuration_emails_url(ri: "jp"), headers: stale_headers

        assert_response :redirect

        query = Rack::Utils.parse_nested_query(URI.parse(response.location).query)
        scope = query["scope"]
        return_to = query["rd"] || query["return_to"]

        assert_equal "configuration_email", scope
        assert_predicate return_to, :present?

        get sign_app_verification_url(scope: scope, rd: return_to, ri: "jp"), headers: stale_headers

        assert_response :success

        post sign_app_verification_emails_url(ri: "jp"),
             params: { verification: { scope: scope, rd: return_to } },
             headers: stale_headers

        assert_response :redirect
        nonce = response.location[%r{/verification/emails/([^/]+)/edit}, 1]

        assert_predicate nonce, :present?
        otp_session = session[:reauth_email_otp]
        code = ROTP::HOTP.new(otp_session["secret"]).at(otp_session["counter"])

        patch sign_app_verification_email_url(nonce, ri: "jp"),
              params: { verification: { code: code, scope: scope, rd: return_to } },
              headers: stale_headers

        assert_response :redirect
        assert_redirected_to sign_app_configuration_emails_url(ri: "jp")
      end

      test "create restores reauth session only when scope and return_to are present" do
        post sign_app_verification_emails_url(ri: "jp"),
             params: { verification: { scope: "", return_to: "" } },
             headers: @headers

        assert_response :redirect
        assert_redirected_to sign_app_verification_url(ri: "jp")

        return_to = Base64.urlsafe_encode64(sign_app_configuration_telephones_path(ri: "jp"))
        post sign_app_verification_emails_url(ri: "jp"),
             params: { verification: { scope: "configuration_telephone", return_to: return_to } },
             headers: @headers

        assert_response :redirect
        assert_match %r{/verification/emails/.+/edit}, response.location
      end
    end
  end
end
