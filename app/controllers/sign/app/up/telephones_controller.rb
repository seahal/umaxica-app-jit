# frozen_string_literal: true

module Sign
  module App
    module Up
      class TelephonesController < ApplicationController
        include CloudflareTurnstile
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
          @user_telephone = UserTelephone.find_by(id: params["id"])
          return if valid_telephone_session?

          redirect_to new_sign_app_up_telephone_path,
                      notice: t("sign.app.registration.telephone.edit.session_expired")
        end

        def create
          @user_telephone = UserTelephone.new(
            params.expect(
              user_telephone: %i(number confirm_policy
                                 confirm_using_mfa),
            ),
          )

          res = cloudflare_turnstile_validation

          unless res["success"]
            @user_telephone.errors.add(:base, t("sign.app.registration.telephone.create.turnstile_validation_failed"))
            render :new, status: :unprocessable_content
            return
          end

          begin
            UserTelephone.transaction do
              # Create pending user
              @pending_user = User.create!(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
              @user_telephone.user = @pending_user
              @user_telephone.user_telephone_status_id = UserTelephoneStatus::UNVERIFIED_WITH_SIGN_UP

              # Generate OTP
              num = generate_otp_attributes(@user_telephone)
              expires_at = @user_telephone.otp_expires_at

              @user_telephone.save!

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
            end
          rescue ActiveRecord::RecordInvalid => e
            @user_telephone = e.record
            render :new, status: :unprocessable_content
          end
        end

        def update
          @user_telephone = UserTelephone.find_by(id: params["id"])

          return redirect_telephone_session_expired unless @user_telephone

          registration_session = session[:user_telephone_registration]
          return render_telephone_session_expired unless valid_registration_session?(registration_session)
          return render_telephone_session_expired if otp_session_expired?(registration_session)
          return render_invalid_telephone_code unless verify_submitted_telephone_code

          verify_telephone!
          if sms_login_ready?
            complete_sms_login!
          else
            finalize_telephone_registration!
          end
        end

        def destroy
          @user_telephone = UserTelephone.find(params[:id])

          unless @user_telephone.user_telephone_status_id == UserTelephoneStatus::VERIFIED_WITH_SIGN_UP
            render :show, status: :unprocessable_content
            return
          end

          @user = @user_telephone.user
          session[:signup_passkey_registration] = {
            "user_id" => @user.id,
            "expires_at" => 30.minutes.from_now.to_i,
          }

          redirect_to new_sign_app_up_passkey_path(ri: params[:ri]),
                      notice: t("sign.app.registration.telephone.update.passkey_required")
        end

        def resend
          registration_session = session[:user_telephone_registration]
          @user_telephone = load_registration_telephone(registration_session)

          if otp_resend_rate_limited?
            flash[:alert] = t("sign.app.registration.telephone.resend.rate_limited")
            return redirect_to resend_redirect_path
          end

          if @user_telephone
            otp_code = generate_otp_for(@user_telephone)
            AwsSmsService.send_message(
              to: @user_telephone.number,
              message: "PassCode => #{otp_code}",
              subject: "PassCode => #{otp_code}",
            )
          else
            perform_dummy_otp_generation
          end

          session[:user_telephone_otp_last_sent_at] = Time.current.to_i
          redirect_to resend_redirect_path,
                      notice: t("sign.app.registration.telephone.resend.sent")
        end

        private

        def valid_telephone_session?
          @user_telephone.present? &&
            !@user_telephone.otp_expired? &&
            @user_telephone.user_telephone_status_id == UserTelephoneStatus::UNVERIFIED_WITH_SIGN_UP
        end

        def boolean_value(value)
          ActiveModel::Type::Boolean.new.cast(value)
        end

        def redirect_telephone_session_expired
          redirect_to new_sign_app_up_telephone_path,
                      notice: t("sign.app.registration.telephone.edit.session_expired")
        end

        def render_telephone_session_expired
          @user_telephone.errors.add(:base, t("sign.app.registration.telephone.edit.session_expired"))
          render :edit, status: :unprocessable_content
        end

        def valid_registration_session?(registration_session)
          registration_session.present? &&
            registration_session["id"].to_s == params["id"].to_s
        end

        def otp_session_expired?(registration_session)
          @user_telephone.otp_expired? ||
            registration_session["expires_at"].to_i <= Time.current.to_i
        end

        def verify_submitted_telephone_code
          submitted_code = params.dig("user_telephone", "pass_code")
          result = verify_otp_code(@user_telephone, submitted_code)
          return true if result[:success]

          increment_otp_attempts!(@user_telephone)
          @user_telephone.errors.add(:pass_code, t("sign.app.registration.telephone.update.invalid_code"))
          false
        end

        def render_invalid_telephone_code
          render :edit, status: :unprocessable_content
        end

        def verify_telephone!
          UserTelephone.transaction do
            # Clear OTP (set confirm flags to avoid validation errors)
            @user_telephone.confirm_policy = "1"
            @user_telephone.confirm_using_mfa = "1"
            clear_otp(@user_telephone)
            # Update status
            @user_telephone.user_telephone_status_id = UserTelephoneStatus::VERIFIED_WITH_SIGN_UP
            @user_telephone.save!
          end
        end

        def finalize_telephone_registration!
          session[:user_telephone_registration] = nil

          session[:signup_passkey_registration] = {
            "user_id" => @user_telephone.user_id,
            "expires_at" => 30.minutes.from_now.to_i,
          }

          redirect_to new_sign_app_up_passkey_path(ri: params[:ri]),
                      notice: t("sign.app.registration.telephone.update.passkey_required")
        end

        def sms_login_ready?
          user = @user_telephone.user
          return false unless user

          user.user_passkeys.active.exists?
        end

        def complete_sms_login!
          user = @user_telephone.user
          return finalize_telephone_registration! unless user

          User.transaction do
            if user.status_id == UserStatus::UNVERIFIED_WITH_SIGN_UP
              user.update!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
            end
          end

          log_in(user, record_login_audit: true)
          session[:user_telephone_registration] = nil
          redirect_to sign_app_configuration_path(ri: params[:ri]),
                      notice: t("sign.app.registration.telephone.update.success")
        end

        def otp_resend_rate_limited?
          last_sent_at = session[:user_telephone_otp_last_sent_at]
          return false if last_sent_at.blank?

          last_sent_at.to_i > 60.seconds.ago.to_i
        end

        def load_registration_telephone(registration_session)
          return nil if registration_session.blank?

          id = registration_session[:id] || registration_session["id"]
          UserTelephone.find_by(id: id)
        end

        def resend_redirect_path
          if @user_telephone
            edit_sign_app_up_telephone_path(@user_telephone.id, ri: params[:ri])
          else
            new_sign_app_up_telephone_path(ri: params[:ri])
          end
        end
      end
    end
  end
end
