module Sign
  module App
    module Setting
      class TotpsController < ApplicationController
        def index
          @totps = UserIdentityOneTimePassword.where(user_id: session[:user])
        end

        def new
          @totp = UserIdentityOneTimePassword.new
          generate_totp_session
        end

        def create
          @totp = UserIdentityOneTimePassword.new(totp_params)
          @totp.private_key = session[:private_key]
          @totp.user = current_user

          if (last_otp_at = verify_totp(@totp.private_key, @totp.first_token))
            @totp.last_otp_at = Time.zone.at(last_otp_at)
            @totp.save!
            session[:private_key] = nil
            redirect_to sign_app_setting_totps_path, notice: t("messages.totp_successfully_created")
          else
            @totp.valid?
            render_totp_qrcode(@totp.private_key)
            render :new, status: :unprocessable_content
          end
        end

        private

        def generate_totp_session
          session[:private_key] ||= ROTP::Base32.random_base32
          @png = generate_qrcode(session[:private_key])
        end

        def render_totp_qrcode(private_key)
          @png = generate_qrcode(private_key)
        end

        def generate_qrcode(private_key)
          totp = ROTP::TOTP.new(private_key)
          RQRCode::QRCode.new(totp.provisioning_uri(account_id)).as_png
        end

        def verify_totp(private_key, token)
          ROTP::TOTP.new(private_key).verify(token)
        end

        def account_id
          # Use user's email address if available, otherwise use public_id
          current_user.user_identity_emails.first&.address || current_user.public_id
        end

        def totp_params
          params.expect(time_based_one_time_password: [ :first_token ])
        end
      end
    end
  end
end
