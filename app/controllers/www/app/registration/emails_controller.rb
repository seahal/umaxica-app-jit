module Www
  module App
    module Registration
      class EmailsController < ApplicationController
        def new
          # FIXME: write test code!
          render plain: t("www.app.authentication.email.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          # # to avoid session attack
          # session[:user_email_address] = nil
          # session[:user_totp_privacy_keys] = nil

          # make user email
          @user_email = UserEmail.new
        end

        def create
          # FIXME: write test code!
          render plain: t("www.app.authentication.email.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          @user_email = UserEmail.new(params.expect(user_email: [ :address, :confirm_policy ]))
          res = cloudflare_turnstile_validation
          id = SecureRandom.random_number(1 << 128)
          otp_private_key = ROTP::Base32.random_base32
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(id)

          # FIXME: use kafka!


          if res["success"] && @user_email.valid?
            session[:user_email_registration] = {
              id: id,
              address: @user_email.address,
              otp_private_key: otp_private_key
            }
            redirect_to edit_www_app_registration_email_path(id), notice: "Email was successfully created."
          else
            render :new, status: :unprocessable_entity
          end
        end

        def edit
          render plain: t("www.app.authentication.email.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          p session[:user_email_registration].to_json["id"]
          p params["id"]
          p session[:user_email_registration]["id"] == params["id"]
          puts "a" * 1000

          if session[:user_email_registration] && session[:user_email_registration]["id"] == params["id"]
            @user_email = UserEmail.new
          else
            redirect_to new_www_app_registration_email_path, notice: t("www.app.registration.email.edit.your_session_was_expired")
          end
        end

        def update
          # FIXME: write test code!
          render plain: t("www.app.authentication.email.new.you_have_already_logged_in"), status: 400 and return if logged_in_staff? || logged_in_user?

          @user_email = UserEmail.new()

          if UserEmail.create(address: "")
            redirect_to @sample, notice: "Sample was successfully updated."
          else
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def cloudflare_turnstile_validation
          # FIXME:
          return { "success" => true }

          res = Net::HTTP.post_form(URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
                                    { "secret" => ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"],
                                      "response" => params["cf-turnstile-response"],
                                      "remoteip" => request.remote_ip })

          JSON.parse(res.body)
        end
      end
    end
  end
end
