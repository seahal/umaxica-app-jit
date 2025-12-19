# frozen_string_literal: true

require "test_helper"

module Sign::App::Registration
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    self.use_transactional_tests = false
    setup do
      # Mock Cloudflare Turnstile validation
      Sign::App::Registration::TelephonesController.send(:define_method, :cloudflare_turnstile_validation) do
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
      UserIdentityTelephone.delete_all
    end

    test "should get new" do
      get new_sign_app_registration_telephone_url

      assert_response :success
    end

    test "should create telephone and redirect to edit" do
      assert_difference("UserIdentityTelephone.count") do
        post sign_app_registration_telephones_url, params: {
          user_identity_telephone: {
            number: "+1234567890",
            confirm_policy: "1",
            confirm_using_mfa: "1"
          }
        }
      end

      telephone = registration_telephone

      assert_redirected_to edit_sign_app_registration_telephone_url(telephone, regional_defaults)
      assert_not_nil session[:user_telephone_registration]
    end

    test "should update telephone with valid otp" do
      # 1. Create telephone via request to set up session
      post sign_app_registration_telephones_url, params: {
        user_identity_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1"
        }
      }
      telephone = registration_telephone

      # 2. Retrieve OTP from DB
      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      # 3. Submit OTP
      patch sign_app_registration_telephone_url(telephone), params: {
        user_identity_telephone: { pass_code: code }
      }

      assert_redirected_to "/"

      telephone.reload

      assert_nil telephone.otp_expires_at # OTP should be cleared
      assert_equal [ nil, nil ], [ telephone.confirm_policy, telephone.confirm_using_mfa ]
    end

    private

    def regional_defaults
      PreferenceConstants::DEFAULT_PREFERENCES.transform_keys(&:to_sym)
    end

    def registration_telephone
      registration_session = session[:user_telephone_registration] || {}
      telephone_id = registration_session[:id] || registration_session["id"]
      UserIdentityTelephone.find(telephone_id)
    end
  end
end
