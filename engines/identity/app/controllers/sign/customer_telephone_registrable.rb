# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module CustomerTelephoneRegistrable
        extend ActiveSupport::Concern

        include Common::Otp

        TELEPHONE_VERIFICATION_RATE_LIMIT = 5
        TELEPHONE_VERIFICATION_RATE_WINDOW = 60

        # Initiates SMS OTP verification for a customer telephone number.
        # Returns true on success, false on validation failure, or :cooldown if the OTP was sent recently.
        # Raises ActionController::TooManyRequests if the per-IP rate limit is exceeded.
        def initiate_customer_telephone_verification(customer, number, auto_accept_confirmations: false)
          return false if customer.blank?

          check_customer_telephone_verification_rate_limit!

          digest = IdentifierBlindIndex.bidx_for_telephone(number)
          existing_telephone =
            digest.present? ? customer.customer_telephones.find_by(number_digest: digest) : nil

          @user_telephone = existing_telephone || customer.customer_telephones.build(raw_number: number)
          @user_telephone.raw_number = number if existing_telephone
          @user_telephone.customer_telephone_status_id = CustomerTelephoneStatus::UNVERIFIED
          if auto_accept_confirmations
            @user_telephone.confirm_policy = true
            @user_telephone.confirm_using_mfa = true
          end

          # Pre-transaction fast-path cooldown check (no lock; avoids unnecessary DB contention).
          if existing_telephone&.otp_cooldown_active?
            return :cooldown
          end

          cooldown_active = false

          CustomerTelephone.transaction do
            if existing_telephone
              locked = CustomerTelephone.lock.find_by(id: existing_telephone.id)
              if locked&.otp_cooldown_active?
                cooldown_active = true
                raise ActiveRecord::Rollback
              end
            end

            # Remove stale unverified records for this number before creating a new one.
            if digest.present? && existing_telephone.blank?
              CustomerTelephone.where(
                number_digest: digest,
                customer_id: customer.id,
                customer_telephone_status_id: CustomerTelephoneStatus::UNVERIFIED,
              ).destroy_all
            end

            otp_number = generate_otp_attributes(@user_telephone)
            return false unless @user_telephone.valid?

            @user_telephone.save!
            send_customer_telephone_verification_sms(@user_telephone, otp_number)
          end

          return :cooldown if cooldown_active

          true
        end

        # Verifies the submitted OTP code for a customer telephone.
        # Returns one of: :success, :session_expired, :invalid_code, :locked
        def complete_customer_telephone_verification(id, submitted_code)
          @user_telephone = CustomerTelephone.find_by(id: id)
          if @user_telephone.blank? ||
              @user_telephone.otp_expired? ||
              @user_telephone.customer_telephone_status_id != CustomerTelephoneStatus::UNVERIFIED
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

          clear_otp(@user_telephone)
          @user_telephone.customer_telephone_status_id = CustomerTelephoneStatus::VERIFIED
          yield(@user_telephone) if block_given?
          :success
        end

        private

        def send_customer_telephone_verification_sms(customer_telephone, otp_number)
          message = I18n.t("sign.telephone_verification.sms_message", code: otp_number)
          SmsDeliveryJob.perform_later(
            to: customer_telephone.number,
            message: message,
            subject: message,
          )
        end

        def check_customer_telephone_verification_rate_limit!
          cache_key = "rate-limit:telephone_verification:#{request.remote_ip}"
          count = RateLimit.store.increment(cache_key, 1, expires_in: TELEPHONE_VERIFICATION_RATE_WINDOW.seconds)
          return unless count && count > TELEPHONE_VERIFICATION_RATE_LIMIT

          Rails.event.notify(
            "telephone.verification.rate_limited",
            ip: request.remote_ip,
            retry_after: TELEPHONE_VERIFICATION_RATE_WINDOW,
          )
          raise ActionController::TooManyRequests
        end
      end
    end
  end
end
