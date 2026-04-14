# typed: false
# frozen_string_literal: true

module Sign
  module TelephoneRegistrable
    extend ActiveSupport::Concern

    class_methods do
      def activate_telephone_registrable
        include Common::Redirect
        include Common::Otp
      end
    end

    TELEPHONE_VERIFICATION_RATE_LIMIT = 5
    TELEPHONE_VERIFICATION_RATE_WINDOW = 60

    # Initiates SMS OTP verification for a telephone number.
    # Returns true on success, false on failure (user blank or validation error),
    # or :cooldown if an OTP was sent within the cooldown period.
    # Raises ActionController::TooManyRequests if rate limit is exceeded.
    def initiate_telephone_verification(user, number, auto_accept_confirmations: false)
      return false if user.blank?

      check_telephone_verification_rate_limit!

      # Compute digest once and reuse for both lookup and stale-record cleanup.
      digest = IdentifierBlindIndex.bidx_for_telephone(number)
      existing_user_telephone = digest.present? ? user.user_telephones.find_by(number_digest: digest) : nil

      @user_telephone = existing_user_telephone || user.user_telephones.build(raw_number: number)
      @user_telephone.raw_number = number if existing_user_telephone
      @user_telephone.user_telephone_status_id = UserTelephoneStatus::UNVERIFIED
      if auto_accept_confirmations
        @user_telephone.confirm_policy = true
        @user_telephone.confirm_using_mfa = true
      end

      # Pre-transaction fast-path cooldown check (no lock; avoids unnecessary DB contention).
      if existing_user_telephone&.otp_cooldown_active?
        return :cooldown
      end

      cooldown_active = false

      UserTelephone.transaction do
        if existing_user_telephone
          locked = UserTelephone.lock.find_by(id: existing_user_telephone.id)
          if locked&.otp_cooldown_active?
            cooldown_active = true
            raise ActiveRecord::Rollback
          end
        end

        # Delete any stale unverified records for this number before creating a new one.
        if digest.present? && existing_user_telephone.blank?
          UserTelephone.where(
            number_digest: digest,
            user_id: user.id,
            user_telephone_status_id: UserTelephoneStatus::UNVERIFIED,
          ).destroy_all
        end

        otp_number = generate_otp_attributes(@user_telephone)
        return false unless @user_telephone.valid?

        @user_telephone.save!
        send_telephone_verification_sms(@user_telephone, otp_number)
      end

      return :cooldown if cooldown_active

      true
    end

    # Returns an existing UserTelephone for the given number or nil.
    # complete_telephone_verification returns one of: :success, :session_expired, :invalid_code, :locked
    def find_existing_user_telephone(user, number)
      digest = IdentifierBlindIndex.bidx_for_telephone(number)
      return nil if digest.blank?

      user.user_telephones.find_by(number_digest: digest)
    end

    def complete_telephone_verification(id, submitted_code)
      @user_telephone = UserTelephone.find_by(id: id)
      if @user_telephone.blank? ||
          @user_telephone.otp_expired? ||
          @user_telephone.user_telephone_status_id != UserTelephoneStatus::UNVERIFIED
        return :session_expired
      end

      result = verify_otp_code(@user_telephone, submitted_code)

      unless result[:success]
        increment_otp_attempts!(@user_telephone)
        if @user_telephone.locked?
          @user_telephone.destroy!
          return :locked
        end
        # NOTE: This key is scoped to the registration flow. If this concern is
        # ever reused in recovery/MFA contexts, add a per-caller i18n key instead.
        @user_telephone.errors.add(:pass_code, t("sign.app.registration.telephone.update.invalid_code"))
        return :invalid_code
      end

      clear_otp(@user_telephone)
      @user_telephone.user_telephone_status_id = UserTelephoneStatus::VERIFIED

      yield(@user_telephone) if block_given?

      :success
    end

    def send_telephone_verification_sms(user_telephone, otp_number)
      message = I18n.t("sign.telephone_verification.sms_message", code: otp_number)
      SmsDeliveryJob.perform_later(
        to: user_telephone.number,
        message: message,
        subject: message,
      )
    end

    private

    def check_telephone_verification_rate_limit!
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
