module Sign
  module Org
    module Registration
      class TelephonesController < ApplicationController
        include ::CloudflareTurnstile

        def new
          @user_telephone = UserTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        def edit
          render plain: t("sign.org.registration.telephone.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?
          render plain: t("sign.org.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          if [ session[:user_telephone_registration]["id"] == params["id"],
              session[:user_telephone_registration]["expires_at"].to_i > Time.now.to_i ].all?
            @user_telephone = UserTelephone.new
          else
            redirect_to new_sign_org_registration_telephone_path,
                        notice: t("sign.org.registration.telephone.edit.your_session_was_expired")
          end
        end

        def create
          render plain: t("sign.org.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          @user_telephone = UserTelephone.new(params.expect(user_telephone: [ :number, :confirm_policy,
                                                                             :confirm_using_mfa ]))

          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32 # NOTE: you would wonder why this code was written ...
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          id = SecureRandom.uuid_v7

          if res["success"] && @user_telephone.valid?
            SmsService.send_message(
              to: @user_telephone.number,
              message: "PassCode => #{num}",
              subject: "PassCode => #{num}"
            )

            session[:user_telephone_registration] = {
              id: id,
              number: @user_telephone.number,
              otp_private_key: otp_private_key,
              otp_counter: otp_count_number,
              expires_at: 12.minutes.from_now.to_i
            }

            redirect_to edit_sign_org_registration_telephone_path(id), notice: t("messages.telephone_successfully_created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          render plain: t("sign.org.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          registration_session = session[:user_telephone_registration]
          if registration_session.blank?
            redirect_to new_sign_org_registration_telephone_path,
                        notice: t("sign.org.registration.telephone.edit.your_session_was_expired") and return
          end

          @user_telephone = UserTelephone.new(number: registration_session["number"],
                                              pass_code: params.dig("user_telephone", "pass_code"))
          otp_verified = otp_verified?(registration_session, @user_telephone.pass_code)
          @user_telephone.errors.add(:pass_code, :invalid) unless otp_verified

          if [
            @user_telephone.valid?,
            registration_session["id"] == params["id"],
            registration_session["expires_at"].to_i > Time.now.to_i,
            otp_verified
          ].all?
            @user_telephone.save!
            session[:user_telephone_registration] = nil
            redirect_to "/", notice: t("sign.org.registration.telephone.update.success")
          else
            render :edit, status: :unprocessable_content
          end
        end

        private

        def otp_verified?(registration_session, submitted_pass_code)
          otp_private_key = registration_session["otp_private_key"]
          otp_counter = registration_session["otp_counter"]
          return false if otp_private_key.blank? || otp_counter.blank? || submitted_pass_code.blank?

          hotp = ROTP::HOTP.new(otp_private_key)
          expected_code = hotp.at(otp_counter.to_i)
          return false if expected_code.blank?
          return false unless expected_code.length == submitted_pass_code.to_s.length

          ActiveSupport::SecurityUtils.secure_compare(expected_code, submitted_pass_code.to_s)
        rescue ArgumentError, ROTP::Base32::Base32Error
          false
        end
      end
    end
  end
end
