# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class TotpsController < ApplicationController
        auth_required!

        include ::Verification::User

        MAX_TOTPS = 2
        before_action :authenticate_user!

        def index
          @totps = current_user.user_one_time_passwords
        end

        def new
          if current_user.user_one_time_passwords.count >= MAX_TOTPS
            return render plain: "#{MAX_TOTPS}件以上は登録できないです"
          end

          @totp = UserOneTimePassword.new
          generate_totp_session
        end

        def edit
          @totp = find_totp
        rescue ActiveRecord::RecordNotFound
          render plain: "Not Found", status: :not_found
        end

        def create
          initialize_totp

          if @totp.private_key.blank?
            redirect_to(
              new_sign_app_configuration_totp_path,
              notice: t("sign.app.registration.email.flow.invalid"),
            )
            return
          end

          last_otp_at = verify_totp(@totp.private_key, @totp.first_token)

          if last_otp_at
            handle_success(last_otp_at)
          else
            handle_failure
          end
        end

        def initialize_totp
          @totp = UserOneTimePassword.new(totp_params)
          @totp.private_key = session[:private_key]
          @totp.user = current_user
          @totp.user_one_time_password_status_id = UserOneTimePasswordStatus::ACTIVE
        end

        def handle_success(last_otp_at)
          @totp.last_otp_at = Time.zone.at(last_otp_at)
          @totp.save!
          session[:private_key] = nil
          audit_totp_enabled!(@totp)
          redirect_to(sign_app_configuration_totps_path, notice: t("messages.totp_successfully_created"))
        end

        def handle_failure
          @totp.valid?
          @totp.errors.add(:first_token, t("sign.app.configuration.totps.invalid_code"))
          render_totp_qrcode(@totp.private_key)
          render :new, status: :unprocessable_content
        end

        def update
          @totp = find_totp
          if @totp.update(update_params)
            redirect_to(
              sign_app_configuration_totps_path,
              notice: t("messages.totp_successfully_updated"),
            )
          else
            render :edit, status: :unprocessable_content
          end
        rescue ActiveRecord::RecordNotFound
          render plain: "Not Found", status: :not_found
        end

        def destroy
          @totp = find_totp
          @totp.destroy!
          audit_totp_disabled!(@totp)
          redirect_to(
            sign_app_configuration_totps_path,
            notice: t("messages.totp_successfully_deleted"),
          )
        rescue ActiveRecord::RecordNotFound
          render plain: "Not Found", status: :not_found
        end

        private

        def find_totp
          current_user.user_one_time_passwords.find_by!(public_id: params[:id])
        end

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
          current_user.user_emails.first&.address || current_user.public_id
        end

        def totp_params
          params.expect(user_one_time_password: [:first_token, :title])
        end

        def update_params
          params.expect(user_one_time_password: [:title])
        end

        def verification_required_action?
          true
        end

        def verification_scope
          "manage_totp"
        end

        def audit_totp_enabled!(totp)
          ActivityRecord.connected_to(role: :writing) do
            UserActivityEvent.find_or_create_by!(id: UserActivityEvent::TOTP_ENABLED)
            UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
          end

          UserActivity.create!(
            actor_type: "User",
            actor_id: current_user.id,
            event_id: UserActivityEvent::TOTP_ENABLED,
            subject_id: totp.id.to_s,
            subject_type: "UserOneTimePassword",
            ip_address: request.remote_ip,
            occurred_at: Time.current,
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.event.error(
            "sign.totp.enable.audit_failed",
            user_id: current_user.id,
            totp_id: totp.id,
            errors: e.record.errors.full_messages,
          )
        end

        def audit_totp_disabled!(totp)
          ActivityRecord.connected_to(role: :writing) do
            UserActivityEvent.find_or_create_by!(id: UserActivityEvent::TOTP_DISABLED)
            UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
          end

          UserActivity.create!(
            actor_type: "User",
            actor_id: current_user.id,
            event_id: UserActivityEvent::TOTP_DISABLED,
            subject_id: totp.id.to_s,
            subject_type: "UserOneTimePassword",
            ip_address: request.remote_ip,
            occurred_at: Time.current,
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.event.error(
            "sign.totp.disable.audit_failed",
            user_id: current_user.id,
            totp_id: totp.id,
            errors: e.record.errors.full_messages,
          )
        end
      end
    end
  end
end
