# frozen_string_literal: true

module Sign
  module TelephoneRegistrable
    extend ActiveSupport::Concern

    included do
      include Common::Redirect
      include Common::Otp
    end

    def initiate_telephone_verification(number)
      # TODO: Rate limit check

      # Normalize number (using existing implementation)
      # Assuming UserTelephone has normalization or similar
      # For now, we trust params or basic validation
      @user_telephone = UserTelephone.new(telephone_number: number)
      @user_telephone.user_telephone_status_id = UserTelephoneStatus::UNVERIFIED

      # Delete existing unverified
      UserTelephone.where(
        telephone_number: @user_telephone.telephone_number,
        user_telephone_status_id: UserTelephoneStatus::UNVERIFIED,
      ).destroy_all

      generate_otp_attributes(@user_telephone)

      unless @user_telephone.valid?
        return false
      end

      @user_telephone.save!

      # Send SMS (Mock or Real)
      # Sms::App::RegistrationMailer equivalent?
      # Assuming SmsService exist
      # Services::SmsService.send(...)

      true
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
  end
end
