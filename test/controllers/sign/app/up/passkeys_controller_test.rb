# frozen_string_literal: true

require "test_helper"

module Sign::App::Up
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      # Mock Cloudflare Turnstile validation
      Sign::App::Up::PasskeysController.send(:define_method, :cloudflare_turnstile_validation) do
        { "success" => true }
      end

      # Mock AWS SMS Service
      if defined?(AwsSmsService)
        @original_aws_sms_service_send_message = AwsSmsService.method(:send_message)
        AwsSmsService.singleton_class.send(:define_method, :send_message) do |**_kwargs|
          true
        end
      end
    end

    teardown do
      if defined?(AwsSmsService) && @original_aws_sms_service_send_message
        original = @original_aws_sms_service_send_message
        AwsSmsService.singleton_class.send(:define_method, :send_message) do |**kwargs|
          original.call(**kwargs)
        end
      end
    end

    test "should get new" do
      get new_sign_app_up_passkey_url

      assert_response :success
    end

    test "should create telephone and redirect to edit" do
      assert_difference("UserTelephone.count") do
        post sign_app_up_passkeys_url, params: {
          user_telephone: {
            number: "+1234567890",
            confirm_policy: "1",
            confirm_using_mfa: "1",
          },
        }
      end

      telephone = registration_telephone

      assert_redirected_to edit_sign_app_up_passkey_url(telephone, regional_defaults)
      assert_not_nil session[:user_telephone_registration]
    end

    test "should update telephone with valid otp" do
      # 1. Create telephone via request to set up session
      post sign_app_up_passkeys_url, params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
      }
      telephone = registration_telephone

      # 2. Retrieve OTP from DB
      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      # 3. Submit OTP
      patch sign_app_up_passkey_url(telephone), params: {
        user_telephone: { pass_code: code },
      }

      assert_redirected_to "/"

      telephone.reload

      # OTP should be cleared (-infinity)
      expires = telephone.otp_expires_at
      assert expires.nil? || expires.to_s == "-infinity" || (expires.is_a?(Float) && expires == -Float::INFINITY)
      assert_equal [nil, nil], [telephone.confirm_policy, telephone.confirm_using_mfa]
    end

    private

    def regional_defaults
      { ri: "jp" }
    end

    def registration_telephone
      registration_session = session[:user_telephone_registration] || {}
      telephone_id = registration_session[:id] || registration_session["id"]
      UserTelephone.find(telephone_id)
    end
  end
end
