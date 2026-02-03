# frozen_string_literal: true

module Sign
  module App
    module Up
      class TelephonesController < ApplicationController
        include Common::Redirect
        include Common::Otp

        before_action :reject_logged_in_session

        def show
        end

        def new
          @user_telephone = UserTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        def edit
          render plain: t("sign.app.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          registration_session = session[:user_telephone_registration]
          if [registration_session["id"] == params["id"],
              registration_session["expires_at"].to_i > Time.now.to_i,].all?
            @user_telephone = UserTelephone.find_by(id: params["id"]) || UserTelephone.new
          else
            redirect_to new_sign_app_up_telephone_path,
                        notice: t("sign.app.registration.telephone.edit.session_expired")
          end
        end

        def create
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

              redirect_to edit_sign_app_up_telephone_path(@user_telephone.id),
                          notice: t("sign.app.registration.telephone.create.verification_code_sent")
            else
              render :new, status: :unprocessable_content
            end
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          # FIXME: write test code!

          @user_telephone = UserTelephone.find_by(id: params["id"])

          if @user_telephone.blank?
            redirect_to new_sign_app_up_telephone_path,
                        notice: t("sign.app.registration.telephone.edit.session_expired") and return
          end

          registration_session = session[:user_telephone_registration]
          if registration_session.blank? || registration_session["id"] != params["id"]
            @user_telephone.errors.add(:base, t("sign.app.registration.telephone.edit.session_expired"))
            render :edit, status: :unprocessable_content and return
          end

          # Retrieve telephone record with OTP
          if @user_telephone.otp_expired? ||
              registration_session["expires_at"].to_i <= Time.now.to_i
            @user_telephone.errors.add(:base, t("sign.app.registration.telephone.edit.session_expired"))
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
          redirect_to sign_app_up_telephone_path(@user_telephone),
                      notice: t("sign.app.registration.telephone.update.success")
        end

        def destroy
        end

        private

        def boolean_value(value)
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
