module Www
  module App
    module Registration
      class EmailsController < ApplicationController
        before_action :set_user_email, only: %i[ show edit  ]

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

          @user_email = UserEmail.new(user_email_params)
          # res = cloudflare_turnstile_validation

          respond_to do |format|
            if @user_email.save # && res["success"] == true
              format.html { redirect_to www_app_registration_email_path(Base64.urlsafe_encode64(@user_email.address)), notice: "Sample was successfully created." }
            else
              format.html { render :new, status: :unprocessable_entity }
            end
          end
        end

        def show
          render plain: "aaa" and return
        end

        def edit
          render plain: "aaa" and return
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_user_email
          @user_email = UserEmail.find(params.expect(:address))
        end

        # Only allow a list of trusted parameters through.
        def user_email_params
          params.expect(user_email: [ :address, :confirm_policy ])
        end

        def cloudflare_turnstile_validation
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
