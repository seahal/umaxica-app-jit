module Sign
  module App
    module Registration
      class TelephonesController < ApplicationController
        include ::CloudflareTurnstile

        def new
          @user_telephone = UserIdentityTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        def edit
          render plain: t("sign.app.registration.telephone.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?
          render plain: t("sign.app.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          if [ session[:user_telephone_registration]["id"] == params["id"],
              session[:user_telephone_registration]["expires_at"].to_i > Time.now.to_i ].all?
            @user_telephone = UserIdentityTelephone.new
          else
            redirect_to new_sign_app_registration_telephone_path,
                        notice: t("sign.app.registration.telephone.edit.your_session_was_expired")
          end
        end

        def create
          render plain: t("sign.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in? || logged_in?

          @user_telephone = UserIdentityTelephone.new(params.expect(user_telephone: [ :number, :confirm_policy,
                                                                             :confirm_using_mfa ]))

          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32 # NOTE: you would wonder why this code was written ...
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          id = SecureRandom.uuid_v7

          if res["success"] && @user_telephone.valid?
            SmsService.send_message(
              to: Rails.application.credentials.dig(:TELEPHONE_FROM_NUMBER),
              message: "PassCode => #{num}",
              subject: "PassCode => #{num}"
            )

            session[:user_telephone_registration] = {
              id: id,
              number: @user_telephone.number,
              confirm_policy: boolean_value(@user_telephone.confirm_policy),
              confirm_using_mfa: boolean_value(@user_telephone.confirm_using_mfa),
              otp_private_key: otp_private_key,
              otp_counter: otp_count_number,
              expires_at: 12.minutes.from_now.to_i
            }

            redirect_to edit_sign_app_registration_telephone_path(id), notice: t("messages.telephone_successfully_created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          # FIXME: write test code!
          render plain: t("sign.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          registration_session = session[:user_telephone_registration]
          if registration_session.blank?
            redirect_to new_sign_app_registration_telephone_path,
                        notice: t("sign.app.registration.telephone.edit.your_session_was_expired") and return
          end

          @user_telephone = UserIdentityTelephone.new(
            number: registration_session["number"],
            pass_code: params.dig("user_telephone", "pass_code"),
            confirm_policy: registration_session.fetch("confirm_policy", true),
            confirm_using_mfa: registration_session.fetch("confirm_using_mfa", true)
          )

          if [
            @user_telephone.valid?,
            registration_session["id"] == params["id"],
            registration_session["expires_at"].to_i > Time.now.to_i
          ].all?
            @user_telephone.save!
            session[:user_telephone_registration] = nil
            redirect_to "/", notice: t("messages.sample_successfully_updated")
          else
            render :edit, status: :unprocessable_content
          end
        end

        private

        def boolean_value(value)
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
