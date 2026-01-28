# frozen_string_literal: true

module Sign
  module App
    module TelephoneRegistrable
      extend ActiveSupport::Concern

      included do
        include ::CloudflareTurnstile
        include Common::Redirect
        include Common::Otp
      end

      def initiate_telephone_verification(number, confirm_policy: "1", confirm_using_mfa: "1", validate_turnstile: true)
        if validate_turnstile
          turnstile_result = cloudflare_turnstile_validation
          unless turnstile_result["success"]
            @user_telephone = UserTelephone.new(
              number: number,
              confirm_policy: confirm_policy,
              confirm_using_mfa: confirm_using_mfa,
            )
            @user_telephone.errors.add(:base, t("sign.app.registration.telephone.create.turnstile_validation_failed"))
            return false
          end
        end

        # TODO: Rate limit check

        @user_telephone = UserTelephone.new(
          number: number,
          confirm_policy: confirm_policy,
          confirm_using_mfa: confirm_using_mfa,
        )
        @user_telephone.user_telephone_status_id = "UNVERIFIED_WITH_SIGN_UP"

        # Delete existing unverified
        UserTelephone.where(
          number: @user_telephone.number,
          user_telephone_status_id: "UNVERIFIED_WITH_SIGN_UP",
        ).destroy_all

        unless @user_telephone.valid?
          return false
        end

        @user_telephone.save!

        otp_code = generate_otp_for(@user_telephone)

        AwsSmsService.send_message(
          to: @user_telephone.number,
          message: "PassCode => #{otp_code}",
          subject: "PassCode => #{otp_code}",
        )

        true
      end

      def complete_telephone_verification(id, submitted_code)
        UserTelephone.transaction do
          @user_telephone = UserTelephone.lock.find_by(id: id)
          if @user_telephone.blank? ||
             @user_telephone.otp_expired? ||
             @user_telephone.user_telephone_status_id != "UNVERIFIED_WITH_SIGN_UP"
            return :already_verified if @user_telephone&.user_telephone_status_id == "VERIFIED_WITH_SIGN_UP"

            return :session_expired
          end

          result = verify_otp_code(@user_telephone, submitted_code)

          unless result[:success]
            increment_otp_attempts!(@user_telephone)
            if @user_telephone.locked?
              @user_telephone.destroy!
              return :locked
            end
            @user_telephone.errors.add(:pass_code, t("sign.app.registration.telephone.update.invalid_code"))
            return :invalid_code
          end

          @user_telephone.user_telephone_status_id = "VERIFIED_WITH_SIGN_UP"
          @user_telephone.assign_attributes(
            otp_nonce: @user_telephone.otp_nonce.to_i + 1,
            otp_counter: "0",
            otp_expires_at: "-infinity",
            otp_attempts_count: 0,
            locked_at: "-infinity",
          )

          yield(@user_telephone) if block_given?

          :success
        end
      end
    end
  end
end
