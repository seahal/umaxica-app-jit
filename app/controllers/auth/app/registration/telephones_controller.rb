module Auth
  module App
    module Registration
      class TelephonesController < ApplicationController
        include ::Cloudflare

        def new
          @user_telephone = UserTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        def create
          render plain: t("www.app.authentication.telephone.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          @user_telephone = UserTelephone.new(params.expect(user_telephone: [ :number, :confirm_policy, :confirm_using_mfa ]))

          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32 # NOTE: you would wonder why this code was written ...
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          id = SecureRandom.uuid_v7

          if res["success"] && @user_telephone.valid?
            SmsService.send_message(
              to: Rails.application.credentials.TELEPHONE_FROM_NUMBER,
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

            redirect_to edit_www_app_registration_telephone_path(id), notice: "Telephone was successfully created."
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          render plain: t("www.app.registration.telephone.edit.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?
          render plain: t("www.app.registration.telephone.edit.forbidden_action"), status: 400 and return if session[:user_telephone_registration].nil?

          if [ session[:user_telephone_registration]["id"] == params["id"],
              session[:user_telephone_registration]["expires_at"].to_i > Time.now.to_i ].all?
            @user_telephone = UserTelephone.new
          else
            redirect_to new_www_app_registration_telephone_path, notice: t("www.app.registration.telephone.edit.your_session_was_expired")
          end
        end

        def update
          # FIXME: write test code!
          render plain: t("www.app.authentication.telephone.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          @user_telephone = UserTelephone.new(number: session[:user_telephone_registration]["number"], pass_code: params["user_telephone"]["pass_code"])

          if [
            @user_telephone.valid?,
            session[:user_telephone_registration]["id"] == params["id"],
            session[:user_telephone_registration]["expires_at"].to_i > Time.now.to_i
          ].all?
            @user_telephone.save!
            session[:user_telephone_registration] = nil
            redirect_to "/", notice: "Sample was successfully updated."
          else
            render :edit, status: :unprocessable_content
          end
        end
      end
    end
  end
end
