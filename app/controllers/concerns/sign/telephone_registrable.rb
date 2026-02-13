# frozen_string_literal: true

module Sign
  module TelephoneRegistrable
    extend ActiveSupport::Concern

    included do
      include Common::Redirect
      include Common::Otp
    end

    def initiate_telephone_verification(user, number, auto_accept_confirmations: false)
      return false if user.blank?

      # TODO: Rate limit check

      existing_user_telephone = find_existing_user_telephone(user, number)
      @user_telephone = existing_user_telephone || user.user_telephones.build(raw_number: number)
      @user_telephone.raw_number = number if existing_user_telephone
      @user_telephone.user_telephone_status_id = UserTelephoneStatus::UNVERIFIED
      @user_telephone.skip_user_presence_validation = false
      if auto_accept_confirmations
        @user_telephone.confirm_policy = true
        @user_telephone.confirm_using_mfa = true
      end

      # Delete existing unverified
      if @user_telephone.number_digest.present? && existing_user_telephone.blank?
        UserTelephone.where(
          number_digest: @user_telephone.number_digest,
          user_id: user.id,
          user_telephone_status_id: UserTelephoneStatus::UNVERIFIED,
        ).destroy_all
      end

      otp_number = generate_otp_attributes(@user_telephone)

      unless @user_telephone.valid?
        return false
      end

      @user_telephone.save!

      send_telephone_verification_sms(@user_telephone, otp_number)

      true
    end

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
        @user_telephone.errors.add(:pass_code, t("sign.app.registration.telephone.update.invalid_code"))
        return :invalid_code
      end

      clear_otp(@user_telephone)
      @user_telephone.user_telephone_status_id = UserTelephoneStatus::VERIFIED

      yield(@user_telephone) if block_given?

      :success
    end

    def send_telephone_verification_sms(user_telephone, otp_number)
      SmsDeliveryJob.perform_later(
        to: user_telephone.number,
        message: "PassCode => #{otp_number}",
        subject: "PassCode => #{otp_number}",
      )
    end
  end
end
