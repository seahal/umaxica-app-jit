module Sign
  module App
    module Registration
      class EmailsController < ApplicationController
        include ::CloudflareTurnstile
        include ::Redirect

        before_action :ensure_not_logged_in

        def new
          # make user email
          @user_email = UserIdentityEmail.new
        end

        def edit
          @user_email = UserIdentityEmail.find_by(id: params["id"])
          if @user_email.blank? || @user_email.otp_expired? || @user_email.user_identity_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = { notice: t("sign.app.registration.email.edit.session_expired") }
            redirect_params[:rd] = params[:rd] if params[:rd].present?
            redirect_to new_sign_app_registration_email_path(redirect_params)
          end
        end

        def create
          # FIXME: write test code!

          # Validate Cloudflare Turnstile first
          turnstile_result = cloudflare_turnstile_validation

          # Build new email record
          @user_email = UserIdentityEmail.new(params.expect(user_identity_email: [ :address, :confirm_policy ]))
          @user_email.user_identity_email_status_id = "UNVERIFIED_WITH_SIGN_UP"

          # Check turnstile validation
          unless turnstile_result["success"]
            @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
            render :new, status: :unprocessable_content and return
          end

          # Delete existing unverified email with same address to allow re-registration
          if @user_email.address.present?
            UserIdentityEmail.where(
              address: @user_email.address,
              user_identity_email_status_id: "UNVERIFIED_WITH_SIGN_UP"
            ).destroy_all
          end

          # Validate the new email
          unless @user_email.valid?
            render :new, status: :unprocessable_content and return
          end

          # Generate OTP
          otp_private_key = ROTP::Base32.random_base32
          otp_count_number = [ Time.now.to_i, SecureRandom.random_number(1 << 64) ].map(&:to_s).join.to_i
          hotp = ROTP::HOTP.new(otp_private_key)
          num = hotp.at(otp_count_number)
          expires_at = 12.minutes.from_now.to_i

          # Save email and store OTP in database
          @user_email.save!
          @user_email.store_otp(otp_private_key, otp_count_number, expires_at)

          # Send email
          # FIXME: use kafka!
          Email::App::RegistrationMailer.with({ hotp_token: num,
                                                email_address: @user_email.address }).create.deliver_now

          # Preserve rd parameter if provided
          redirect_params = { notice: t("sign.app.registration.email.create.verification_code_sent") }
          redirect_params[:rd] = params[:rd] if params[:rd].present?

          redirect_to edit_sign_app_registration_email_path(@user_email.id, redirect_params)
        end

        def update
          # FIXME: write test code!
          # Retrieve email record with OTP
          @user_email = UserIdentityEmail.find_by(id: params["id"])
          if @user_email.blank? || @user_email.otp_expired? || @user_email.user_identity_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = { alert: t("sign.app.registration.email.update.session_expired") }
            redirect_params[:rd] = params[:rd] if params[:rd].present?
            redirect_to new_sign_app_registration_email_path(redirect_params) and return
          end

          # Verify OTP using secure_compare
          submitted_code = params["user_identity_email"]["pass_code"]
          otp_data = @user_email.get_otp
          if otp_data.blank? || submitted_code.blank?
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Verify OTP with timing attack protection
          hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
          expected_code = hotp.at(otp_data[:otp_counter]).to_s
          unless ActiveSupport::SecurityUtils.secure_compare(expected_code, submitted_code)
            @user_email.increment_attempts!
            if @user_email.locked?
              @user_email.destroy!
              redirect_params = { alert: t("sign.app.registration.email.update.attempts_exceeded") }
              redirect_params[:rd] = params[:rd] if params[:rd].present?
              redirect_to new_sign_app_registration_email_path(redirect_params) and return
            end
            @user_email.errors.add(:pass_code, t("sign.app.registration.email.update.invalid_code"))
            render :edit, status: :unprocessable_content and return
          end

          # Clear OTP and complete registration
          @user_email.clear_otp
          @user_email.user_identity_email_status_id = "VERIFIED_WITH_SIGN_UP"

          # Create user and link email atomically within a transaction
          begin
            ActiveRecord::Base.transaction do
              # Use create! to raise exception on validation failure
              @user = User.create!(user_identity_status_id: "VERIFIED_WITH_SIGN_UP")
              # Use association to set the user
              @user_email.user = @user
              UserIdentityAudit.create!(user: @user, actor: @user, event_id: "SIGNED_UP_WITH_EMAIL")
              @user_email.save!
            end
          rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
            @user_email.errors.add(:base, t("sign.app.registration.email.update.failed"))
            render :edit, status: :unprocessable_content and return
          end

          # Set user session after successful transaction
          log_in(@user)

          # Redirect to rd parameter if provided, otherwise to root
          if params[:rd].present?
            flash[:notice] = t("sign.app.registration.email.update.success")
            jump_to_generated_url(params[:rd])
          else
            redirect_to "/", notice: t("sign.app.registration.email.update.success")
          end
        end

        private

        def ensure_not_logged_in
          if logged_in?
            redirect_to "/", alert: t("sign.app.registration.email.already_logged_in")
          end
        end
      end
    end
  end
end
