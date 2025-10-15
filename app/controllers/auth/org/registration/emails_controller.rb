module Auth
  module Org
    module Registration
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include ::Redirect

        def new
          # FIXME: write test code!
          render plain: t("auth.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          # # to avoid session attack
          session[:user_email_registration] = nil

          # make user email
          @user_email = UserEmail.new
        end

        def edit
          render plain: t("auth.app.registration.email.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?
          render plain: t("auth.app.registration.email.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_email_registration].nil?

          if session[:user_email_registration] && session[:user_email_registration]["id"] == params["id"] && session[:user_email_registration]["expires_at"].to_i > Time.now.to_i
            @user_email = UserEmail.new
          else
            redirect_to new_apex_app_registration_email_path,
                        notice: t("auth.app.registration.email.edit.your_session_was_expired")
          end
        end

        def create
          # FIXME: write test code!
          render plain: t("auth.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_email = UserEmail.new(params.expect(user_email: [ :address, :confirm_policy ]))
          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32 # NOTE: you would wonder why this code was written ...
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          id = SecureRandom.uuid_v7

          if res["success"] && @user_email.valid?
            session[:user_email_registration] = {
              id: id,
              address: @user_email.address,
              otp_private_key: otp_private_key,
              otp_counter: otp_count_number,
              expires_at: 12.minutes.from_now.to_i
            }

            # FIXME: use kafka!
            Email::App::EmailRegistrationMailer.with({ hotp_token: num,
                                                       mail_address: @user_email.address }).create.deliver_now

            redirect_to edit_apex_app_registration_email_path(id), notice: t("messages.email_successfully_created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          # FIXME: write test code!
          render plain: t("auth.app.authentication.email.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          @user_email = UserEmail.new(address: session[:user_email_registration]["address"],
                                      pass_code: params["user_email"]["pass_code"])

          if [
            @user_email.valid?,
            session[:user_email_registration]["id"] == params["id"],
            session[:user_email_registration]["expires_at"].to_i > Time.now.to_i
          ].all?
            @user_email.save!
            session[:user_email_registration] = nil
            redirect_to "/", notice: t("messages.sample_successfully_updated")
          else
            render :edit, status: :unprocessable_content
          end
        end
      end
    end
  end
end
