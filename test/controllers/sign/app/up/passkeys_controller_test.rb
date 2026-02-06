# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

module Sign::App::Up
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    fixtures :user_statuses, :user_telephone_statuses, :user_secret_kinds, :user_secret_statuses

    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")

      CloudflareTurnstile.test_mode = true
      CloudflareTurnstile.test_validation_response = { "success" => true }

      if defined?(AwsSmsService)
        @original_aws_sms_service_send_message = AwsSmsService.method(:send_message)
        AwsSmsService.singleton_class.send(:define_method, :send_message) do |**_kwargs|
          true
        end
      end

      @original_trusted_origins = Webauthn.method(:trusted_origins)
      Webauthn.define_singleton_method(:trusted_origins) { ["http://sign.app.localhost"] }
    end

    teardown do
      CloudflareTurnstile.test_mode = false
      CloudflareTurnstile.test_validation_response = nil

      if defined?(AwsSmsService) && @original_aws_sms_service_send_message
        original = @original_aws_sms_service_send_message
        AwsSmsService.singleton_class.send(:define_method, :send_message) do |**kwargs|
          original.call(**kwargs)
        end
      end

      Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
    end

    test "passkey registration completes signup and issues emergency key" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone

      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
        user_telephone: { pass_code: code },
      }

      post options_sign_app_up_passkeys_url(ri: "jp")
      challenge_id = response.parsed_body["challenge_id"]

      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { "signup_webauthn_id" }
      mock_credential.define_singleton_method(:public_key) { "signup_public_key" }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub :from_create, mock_credential do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: "signup_webauthn_id",
            rawId: "signup_webauthn_id",
            type: "public-key",
            response: { clientDataJSON: "e30=", attestationObject: "e30=" },
          },
          description: "Signup Passkey",
        }

        assert_difference("UserPasskey.count", 1) do
          assert_difference("UserSecret.count", 1) do
            post sign_app_up_passkeys_url(ri: "jp"), params: params
          end
        end
      end

      assert_response :created
      json = response.parsed_body
      assert_equal "ok", json["status"]
      assert_equal sign_app_configuration_emergency_key_path(ri: "jp"), json["redirect_url"]
      assert_predicate cookies[Auth::Base::ACCESS_COOKIE_KEY], :present?
    end

    private

    def registration_telephone
      registration_session = session[:user_telephone_registration] || {}
      telephone_id = registration_session[:id] || registration_session["id"]
      UserTelephone.find(telephone_id)
    end
  end
end
