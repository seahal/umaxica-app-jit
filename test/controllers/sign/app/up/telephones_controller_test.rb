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

    test "create with existing telephone still redirects and does not create a new record" do
      user = User.create!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
      existing_telephone = UserTelephone.create!(
        user: user,
        number: "+1234567898",
        user_telephone_status_id: UserTelephoneStatus::VERIFIED,
        confirm_policy: "1",
        confirm_using_mfa: "1",
      )

      assert_no_difference("User.count") do
        assert_no_difference("UserTelephone.count") do
          post sign_app_up_telephones_url(ri: "jp"), params: {
            user_telephone: {
              number: existing_telephone.number,
              confirm_policy: "1",
              confirm_using_mfa: "1",
            },
            "cf-turnstile-response": "test",
          }
        end
      end

      assert_redirected_to edit_sign_app_up_telephone_url(existing_telephone, regional_defaults)
      assert_equal I18n.t("sign.app.registration.telephone.create.verification_code_sent"), flash[:notice]
      assert_nil flash[:alert]
    end

    test "rejects invalid telephone format" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "invalid-telephone",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }

      assert_response :unprocessable_content
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

      assert_redirected_to sign_app_up_telephone_passkey_registration_url(telephone, regional_defaults)

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

      UserEmail.create!(
        user: user,
        address: "test_verified_#{user.id}@example.com",
        user_email_status_id: UserEmailStatus::VERIFIED,
        otp_private_key: ROTP::Base32.random,
      )

      UserPasskey.create!(
        user: user,
        webauthn_id: Base64.urlsafe_encode64("preexisting_passkey", padding: false),
        public_key: "public_key",
        sign_count: 0,
        description: "Existing Passkey",
        status_id: UserPasskeyStatus::ACTIVE,
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

    test "should create audit record on sms login with existing passkey" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567892",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone
      user = telephone.user

      UserEmail.create!(
        user: user,
        address: "audit_test_verified_#{user.id}@example.com",
        user_email_status_id: UserEmailStatus::VERIFIED,
        otp_private_key: ROTP::Base32.random,
      )

      UserPasskey.create!(
        user: user,
        webauthn_id: Base64.urlsafe_encode64("audit_test_passkey", padding: false),
        public_key: "public_key",
        sign_count: 0,
        description: "Audit Test Passkey",
        status_id: UserPasskeyStatus::ACTIVE,
      )

      otp_data = telephone.get_otp
      hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
      code = hotp.at(otp_data[:otp_counter])

      patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
        user_telephone: { pass_code: code },
      }

      signup_audit = UserAudit.where(
        event_id: UserAuditEvent::SIGNED_UP_WITH_TELEPHONE,
        actor_id: user.id,
      ).last
      assert_not_nil signup_audit
      assert_equal "User", signup_audit.actor_type
    end

    test "should reject blank pass code" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567890",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone

      patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
        user_telephone: { pass_code: "" },
      }

      assert_response :unprocessable_content
    end

    test "should lockout after max failed otp attempts" do
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567893",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      telephone = registration_telephone
      user = telephone.user

      # Submit wrong OTP 3 times (max attempts)
      3.times do
        patch sign_app_up_telephone_url(telephone, ri: "jp"), params: {
          user_telephone: { pass_code: "000000" },
        }
      end

      assert_redirected_to new_sign_app_up_telephone_url(ri: "jp")
      assert_equal I18n.t("sign.app.registration.telephone.update.attempts_exceeded"), flash[:alert]

      # Telephone and pending user should be destroyed
      assert_not UserTelephone.exists?(telephone.id)
      assert_not User.exists?(user.id)
      assert_nil session[:user_telephone_registration]
    end

    test "should cleanup existing unverified telephones on create" do
      # Create first registration
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567894",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }
      first_telephone = registration_telephone
      first_user = first_telephone.user

      # Create second registration with the same number
      post sign_app_up_telephones_url(ri: "jp"), params: {
        user_telephone: {
          number: "+1234567894",
          confirm_policy: "1",
          confirm_using_mfa: "1",
        },
        "cf-turnstile-response": "test",
      }

      # First telephone and its pending user should be cleaned up
      assert_not UserTelephone.exists?(first_telephone.id)
      assert_not User.exists?(first_user.id)
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

    test "resend cooldown is 30 seconds" do
      post resend_sign_app_up_telephones_url(ri: "jp")
      sent_at = session[:user_telephone_otp_last_sent_at]
      assert_predicate sent_at, :present?
      assert_redirected_to new_sign_app_up_telephone_url(ri: "jp")
      assert_equal I18n.t("sign.app.registration.telephone.resend.sent"), flash[:notice]

      travel 29.seconds do
        post resend_sign_app_up_telephones_url(ri: "jp")
        assert_redirected_to new_sign_app_up_telephone_url(ri: "jp")
        assert_equal I18n.t("sign.app.registration.telephone.resend.rate_limited"), flash[:alert]
      end

      travel 31.seconds do
        post resend_sign_app_up_telephones_url(ri: "jp")
        assert_redirected_to new_sign_app_up_telephone_url(ri: "jp")
        assert_equal I18n.t("sign.app.registration.telephone.resend.sent"), flash[:notice]
      end
    end

    private

    def regional_defaults
      { ri: "jp" }
    end

    def registration_telephone
      registration_session = session[:user_telephone_registration] || {}
      public_id = registration_session[:public_id] || registration_session["public_id"]
      UserTelephone.find_by!(public_id: public_id)
    end
  end
end
