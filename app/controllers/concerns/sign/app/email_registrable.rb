# frozen_string_literal: true

module Sign
  module App
    module EmailRegistrable
      extend ActiveSupport::Concern

      included do
        include ::CloudflareTurnstile
        include Common::Redirect
        include Common::Otp
      end

      def initiate_email_verification(email_address, confirm_policy: "1", validate_turnstile: true)
        # Validate Cloudflare Turnstile (optional for flows without widget)
        if validate_turnstile
          turnstile_result = cloudflare_turnstile_validation
          unless turnstile_result["success"]
            @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
            @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
            return false
          end
        end

        @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
        @user_email.user_email_status_id = "UNVERIFIED_WITH_SIGN_UP"

        # Rate limit check (TODO: Implement rate limiting)
        # if rate_limited? ...

        # Delete existing unverified email
        UserEmail.where(
          address: @user_email.address,
          user_email_status_id: "UNVERIFIED_WITH_SIGN_UP",
        ).destroy_all

        unless @user_email.valid?
          return false
        end

        @user_email.save!

        num = generate_otp_for(@user_email)
        token = @user_email.generate_verification_token

        Email::App::RegistrationMailer.with(
          hotp_token: num,
          email_address: @user_email.address,
          verification_token: token,
          public_id: @user_email.public_id,
        ).create.deliver_later

        true
      end

      def complete_email_verification(id, submitted_code, token = nil)
        UserEmail.transaction do
          @user_email = UserEmail.lock.find_by(public_id: id)

          if @user_email.blank? ||
             @user_email.otp_expired? ||
             @user_email.user_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            return :already_verified if @user_email&.user_email_status_id == "VERIFIED_WITH_SIGN_UP"

            @error_redirect = new_sign_app_up_email_path # default, override in controller if needed
            return :session_expired
          end

          # Verify token if provided (strict verification)
          if token.present?
            unless @user_email.verify_verification_token(token)
              @user_email.errors.add(:base, t("sign.app.registration.email.update.invalid_token"))
              return :invalid_token
            end
          end

          result = verify_otp_code(@user_email, submitted_code)

          unless result[:success]
            increment_otp_attempts!(@user_email)
            if @user_email.locked?
              @user_email.destroy!
              return :locked
            end
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            return :invalid_code
          end

          @user_email.user_email_status_id = "VERIFIED_WITH_SIGN_UP"
          @user_email.assign_attributes(
            otp_nonce: @user_email.otp_nonce.to_i + 1,
            otp_counter: "0",
            otp_expires_at: "-infinity",
            otp_attempts_count: 0,
            locked_at: "-infinity",
            otp_last_sent_at: "-infinity",
          )

          yield(@user_email) if block_given?

          :success
        end
      end
    end
  end
end
