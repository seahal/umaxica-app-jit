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

      def initiate_email_verification!(email_address, confirm_policy: "1")
        # Validate Cloudflare Turnstile
        turnstile_result = cloudflare_turnstile_validation
        unless turnstile_result["success"]
          @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
          @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
          raise ActiveRecord::RecordInvalid.new(@user_email)
        end

        @user_email = UserEmail.new(address: email_address, confirm_policy: confirm_policy)
        @user_email.user_email_status_id = "UNVERIFIED_WITH_SIGN_UP"

        # Rate limit check (TODO: Implement rate limiting)
        # if rate_limited? ...

        UserEmail.transaction do
          # Delete existing unverified email
          UserEmail.where(
            address: @user_email.address,
            user_email_status_id: "UNVERIFIED_WITH_SIGN_UP",
          ).destroy_all

          # Generate OTP
          num = generate_otp_attributes(@user_email)

          @user_email.save!

          token = @user_email.generate_verification_token

          Email::App::RegistrationMailer.with(
            hotp_token: num,
            email_address: @user_email.address,
            verification_token: token,
            public_id: @user_email.public_id,
          ).create.deliver_later
        end

        true
      end

      def complete_email_verification!(id, submitted_code, token = nil)
        @user_email = UserEmail.find_by(public_id: id)

        if @user_email.blank? ||
            @user_email.otp_expired? ||
            @user_email.user_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
          @error_redirect = new_sign_app_up_email_path # default, override in controller if needed
          raise ApplicationError.new(I18n.t("errors.session_expired"), status_code: :gone)
        end

        # Verify token if provided (strict verification)
        if token.present?
          unless @user_email.verify_verification_token(token)
            @user_email.errors.add(:base, t("sign.app.registration.email.update.invalid_token"))
            raise ActiveRecord::RecordInvalid.new(@user_email)
          end
        end

        result = verify_otp_code(@user_email, submitted_code)

        unless result[:success]
          increment_otp_attempts!(@user_email)
          if @user_email.locked?
            @user_email.destroy!
            raise ApplicationError.new(I18n.t("errors.otp_locked"), status_code: :forbidden)
          end
          @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
          raise ActiveRecord::RecordInvalid.new(@user_email)
        end

        @user_email.transaction do
          clear_otp(@user_email)
          @user_email.user_email_status_id = "VERIFIED_WITH_SIGN_UP"

          yield(@user_email) if block_given?
        end

        true
      end
    end
  end
end
