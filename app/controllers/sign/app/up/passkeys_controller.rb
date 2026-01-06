# frozen_string_literal: true

module Sign
  module App
    module Up
      class PasskeysController < ApplicationController
        include ::Redirect
        include Sign::OtpAuthentication

        # todo: verify not logged in
        def new
          @user_telephone = UserTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        # todo: verify not logged in
        def edit
          render plain: t("sign.app.registration.telephone.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?
          render plain: t("sign.app.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          registration_session = session[:user_telephone_registration]
          if [registration_session["id"] == params["id"],
              registration_session["expires_at"].to_i > Time.now.to_i,].all?
            @user_telephone = UserTelephone.find_by(id: params["id"]) || UserTelephone.new
          else
            redirect_to new_sign_app_up_passkey_path,
                        notice: t("sign.app.registration.telephone.edit.session_expired")
          end
        end

        # todo: verify not logged in
        def create
          render plain: t("sign.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          @user_telephone = UserTelephone.new(
            params.expect(
              user_telephone: %i(number confirm_policy
                                 confirm_using_mfa),
            ),
          )

          res = cloudflare_turnstile_validation
          num = generate_otp_attributes(@user_telephone)
          expires_at = @user_telephone.otp_expires_at

          if res["success"]

            if @user_telephone.valid?
              # Save telephone and store OTP in database
              @user_telephone.save!
              # @user_telephone.store_otp(otp_private_key, otp_count_number, expires_at) # Already set above

              # Store only the reference ID and expiry in session
              session[:user_telephone_registration] = {
                id: @user_telephone.id,
                confirm_policy: boolean_value(@user_telephone.confirm_policy),
                confirm_using_mfa: boolean_value(@user_telephone.confirm_using_mfa),
                expires_at: expires_at.to_i,
              }

              # Send SMS with OTP
              AwsSmsService.send_message(
                to: @user_telephone.number,
                message: "PassCode => #{num}",
                subject: "PassCode => #{num}",
              )

              redirect_to edit_sign_app_up_passkey_path(@user_telephone.id),
                          notice: t("sign.app.registration.telephone.create.verification_code_sent")
            else
              render :new, status: :unprocessable_content
            end
          else
            render :new, status: :unprocessable_content
          end
        end

        # todo: verify not logged in
        def update
          # FIXME: write test code!
          render plain: t("sign.app.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in?

          registration_session = session[:user_telephone_registration]
          if registration_session.blank? || registration_session["id"] != params["id"]
            render :edit, status: :unprocessable_content and return
          end

          # Retrieve telephone record with OTP
          @user_telephone = UserTelephone.find_by(id: params["id"])
          if @user_telephone.blank? ||
              @user_telephone.otp_expired? ||
              registration_session["expires_at"].to_i <= Time.now.to_i
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP using secure_compare
          submitted_code = params.dig("user_telephone", "pass_code")
          result = verify_otp_code(@user_telephone, submitted_code)

          unless result[:success]
            increment_otp_attempts!(@user_telephone)
            @user_telephone.errors.add(:pass_code, t("sign.app.registration.telephone.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Update attributes and clear OTP
          @user_telephone.update!(
            confirm_policy: registration_session.fetch("confirm_policy", true),
            confirm_using_mfa: registration_session.fetch("confirm_using_mfa", true),
          )
          clear_otp(@user_telephone)
          session[:user_telephone_registration] = nil
          redirect_to "/", notice: t("sign.app.registration.telephone.update.success")
        end

        private

        def boolean_value(value)
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
