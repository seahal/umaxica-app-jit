# frozen_string_literal: true

require "test_helper"
require "base64"

module Sign::App::Up
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    fixtures :app_preference_audit_levels, :app_preference_audit_events,
             :user_statuses, :user_telephone_statuses,
             :user_audit_events, :user_audit_levels

    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      # Mock Cloudflare Turnstile validation
      CloudflareTurnstile.test_mode = true
      CloudflareTurnstile.test_validation_response = { "success" => true }

      # Mock AWS SMS Service
      if defined?(AwsSmsService)
        @original_aws_sms_service_send_message = AwsSmsService.method(:send_message)
        AwsSmsService.singleton_class.send(:define_method, :send_message) do |**_kwargs|
          true
        end
      end
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
    end

    test "should get new" do
      get new_sign_app_up_telephone_url(ri: "jp")

      assert_response :success
    end

    test "should get show" do
      # Show requires an ID, using a dummy one or creating one if needed, though controller action is empty
      user = User.create!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
      telephone = UserTelephone.create!(
        number: "+10000000000",
        user: user,
        user_telephone_status_id: UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
      )
      get sign_app_up_telephone_url(telephone, ri: "jp")

      assert_response :success
      assert_select "h2", text: "登録が完了しました"
    end

    test "should create telephone and redirect to edit" do
      assert_difference("UserTelephone.count") do
        post sign_app_up_telephones_url(ri: "jp"), params: {
          user_telephone: {
            number: "+1234567890",
            confirm_policy: "1",
            confirm_using_mfa: "1",
          },
          "cf-turnstile-response": "test",
        }
      end

      telephone = registration_telephone

      assert_redirected_to edit_sign_app_up_telephone_url(telephone, regional_defaults)
      assert_not_nil session[:user_telephone_registration]
    end

    test "should update telephone with valid otp" do
      # 1. Create telephone via request to set up session
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone

      # 2. Retrieve OTP from DB
      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      # 3. Submit OTP
      patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
        user_telephone: { pass_code: code },
      }

      assert_redirected_to new_sign_app_up_passkey_url(regional_defaults)

      telephone.reload

      # OTP should be cleared (-infinity)
      expires = telephone.otp_expires_at
      assert expires.nil? || expires.to_s == "-infinity" || (expires.is_a?(Float) && expires == -Float::INFINITY)
      assert_equal [nil, nil], [telephone.confirm_policy, telephone.confirm_using_mfa]
    end

    test "should log in after sms verification when passkey already exists" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567891",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone
      user = telephone.user

      UserPasskey.create!(
        user: user,
        webauthn_id: Base64.urlsafe_encode64("preexisting_passkey", padding: false),
        public_key: "public_key",
        sign_count: 0,
        description: "Existing Passkey",
        user_passkey_status_id: UserPasskeyStatus::ACTIVE,
      )

      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      assert_difference("UserToken.count", 1) do
        patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
          user_telephone: { pass_code: code },
        }
      end

      assert_redirected_to sign_app_configuration_url(ri: "jp")
      assert_predicate cookies[Auth::Base::ACCESS_COOKIE_KEY], :present?
    end

    test "should require passkey registration on destroy when verified" do
      user = User.create!(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
      telephone = UserTelephone.create!(
        number: "+10000000001",
        user: user,
        user_telephone_status_id: UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
      )

      assert_no_difference("UserToken.count") do
        delete sign_app_up_telephone_url(telephone, ri: "jp")
      end

      assert_redirected_to new_sign_app_up_passkey_url(ri: "jp")
      assert_equal UserStatus::UNVERIFIED_WITH_SIGN_UP, user.reload.status_id
      assert_not UserToken.exists?(user_id: user.id, revoked_at: nil)
    end

    test "should not complete signup on destroy when unverified" do
      user = User.create!(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
      telephone = UserTelephone.create!(
        number: "+10000000002",
        user: user,
        user_telephone_status_id: UserTelephoneStatus::UNVERIFIED_WITH_SIGN_UP,
      )

      assert_no_difference("UserToken.count") do
        delete sign_app_up_telephone_url(telephone, ri: "jp")
      end

      assert_response :unprocessable_content
      assert_equal UserStatus::UNVERIFIED_WITH_SIGN_UP, user.reload.status_id
    end

    test "resend sends code for active registration session" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone

      post resend_sign_app_up_telephones_url(ri: "jp")

      assert_redirected_to edit_sign_app_up_telephone_url(telephone, ri: "jp")
      assert_predicate session[:user_telephone_otp_last_sent_at], :present?
    end

    test "resend returns success even without registration session" do
      assert_no_difference("UserTelephone.count") do
        post resend_sign_app_up_telephones_url(ri: "jp")
      end

      assert_redirected_to new_sign_app_up_telephone_url(ri: "jp")
    end

    test "resend rate limits repeated requests" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone

      post resend_sign_app_up_telephones_url(ri: "jp")
      post resend_sign_app_up_telephones_url(ri: "jp")

      assert_redirected_to edit_sign_app_up_telephone_url(telephone, ri: "jp")
      assert_equal I18n.t("sign.app.registration.telephone.resend.rate_limited"), flash[:alert]
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
