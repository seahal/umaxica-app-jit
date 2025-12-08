module Sign
  module Org
    module Registration
      class TelephonesController < ApplicationController
        include ::CloudflareTurnstile

        def new
          @user_telephone = UserIdentityTelephone.new

          # # to avoid session attack
          session[:user_telephone_registration] = nil
        end

        def edit
          render plain: t("sign.org.registration.telephone.edit.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?
          render plain: t("sign.org.registration.telephone.edit.forbidden_action"),
                 status: :bad_request and return if session[:user_telephone_registration].nil?

          registration_session = session[:user_telephone_registration]
          if [ registration_session["id"] == params["id"],
              registration_session["expires_at"].to_i > Time.now.to_i ].all?
            @user_telephone = UserIdentityTelephone.find_by(id: params["id"]) || UserIdentityTelephone.new
          else
            redirect_to new_sign_org_registration_telephone_path,
                        notice: t("sign.org.registration.telephone.edit.your_session_was_expired")
          end
        end

        def create
          render plain: t("sign.org.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          @user_telephone = UserIdentityTelephone.new(params.expect(user_telephone: [ :number, :confirm_policy,
                                                                                     :confirm_using_mfa ]))

          res = cloudflare_turnstile_validation
          otp_private_key = ROTP::Base32.random_base32
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          expires_at = 12.minutes.from_now.to_i

          if res["success"] && @user_telephone.valid?
            # Save telephone and store OTP in database
            @user_telephone.save!
            @user_telephone.store_otp(otp_private_key, otp_count_number, expires_at)

            # Store only the reference ID and expiry in session
            session[:user_telephone_registration] = {
              id: @user_telephone.id,
              confirm_policy: boolean_value(@user_telephone.confirm_policy),
              confirm_using_mfa: boolean_value(@user_telephone.confirm_using_mfa),
              expires_at: expires_at
            }

            # Send SMS with OTP
            AwsSmsService.send_message(
              to: @user_telephone.number,
              message: "PassCode => #{num}",
              subject: "PassCode => #{num}"
            )

            redirect_to edit_sign_org_registration_telephone_path(@user_telephone.id), notice: t("messages.telephone_successfully_created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          render plain: t("sign.org.authentication.telephone.new.you_have_already_logged_in"),
                 status: :bad_request and return if logged_in_staff? || logged_in_user?

          registration_session = session[:user_telephone_registration]
          if registration_session.blank? || registration_session["id"] != params["id"]
            redirect_to new_sign_org_registration_telephone_path,
                        notice: t("sign.org.registration.telephone.edit.your_session_was_expired") and return
          end

          # Retrieve telephone record with OTP
          @user_telephone = UserIdentityTelephone.find_by(id: params["id"])
          if @user_telephone.blank? || @user_telephone.otp_expired? || registration_session["expires_at"].to_i <= Time.now.to_i
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP using secure_compare
          submitted_code = params.dig("user_telephone", "pass_code")
          otp_data = @user_telephone.get_otp
          if otp_data.blank? || submitted_code.blank?
            @user_telephone.errors.add(:pass_code, t("sign.org.registration.telephone.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP with timing attack protection
          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s
          unless ActiveSupport::SecurityUtils.secure_compare(expected_code, submitted_code)
            @user_telephone.errors.add(:pass_code, t("sign.org.registration.telephone.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Update attributes and clear OTP
          @user_telephone.update!(
            confirm_policy: registration_session.fetch("confirm_policy", true),
            confirm_using_mfa: registration_session.fetch("confirm_using_mfa", true)
          )
          @user_telephone.clear_otp
          session[:user_telephone_registration] = nil
          redirect_to "/", notice: t("sign.org.registration.telephone.update.success")
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

        def boolean_value(value)
          ActiveModel::Type::Boolean.new.cast(value)
        end
      end
    end
  end
end
