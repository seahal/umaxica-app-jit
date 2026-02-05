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
          # FIXME: write test code!

          @user_telephone = UserTelephone.find_by(id: params["id"])

          if @user_telephone.blank?
            redirect_to new_sign_app_up_telephone_path,
                        notice: t("sign.app.registration.telephone.edit.session_expired") and return
          end

          registration_session = session[:user_telephone_registration]
          if registration_session.blank? || registration_session["id"].to_s != params["id"].to_s
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

          UserTelephone.transaction do
            # Clear OTP (set confirm flags to avoid validation errors)
            @user_telephone.confirm_policy = "1"
            @user_telephone.confirm_using_mfa = "1"
            clear_otp(@user_telephone)
            # Update status
            @user_telephone.user_telephone_status_id = UserTelephoneStatus::VERIFIED_WITH_SIGN_UP
            @user_telephone.save!

            # Update user status and login
            @user = @user_telephone.user
            @user.update!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)

            # Create audit record
            audit = UserAudit.new
            audit.actor_type = "User"
            audit.actor_id = @user.id
            audit.event_id = UserAuditEvent::SIGNED_UP_WITH_TELEPHONE
            audit.subject_id = @user.id.to_s
            audit.subject_type = "User"
            audit.save!

            log_in(@user, record_login_audit: false)
          end

          session[:user_telephone_registration] = nil
          redirect_to sign_app_up_telephone_path(@user_telephone),
                      notice: t("sign.app.registration.telephone.update.success")
        end

        def destroy
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
      end
    end
  end
end
