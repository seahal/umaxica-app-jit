# frozen_string_literal: true

module Sign
  module App
    module In
      class TotpsController < ApplicationController
        include Common::Redirect
        include SessionLimitGate

        MFA_USER_SESSION_KEY = :mfa_user_id

        TotpChallengeForm =
          Struct.new(:token, keyword_init: true) do
            include ActiveModel::Model

            validates :token, presence: true, length: { is: 6 }

            def self.model_name
              ActiveModel::Name.new(self, nil, "totp_challenge_form")
            end
          end

        before_action :reject_logged_in_session
        before_action :ensure_mfa_user!

        def new
          @totp_form = TotpChallengeForm.new
          @secret_hints = active_secret_hints_for(mfa_user)
        end

        def create
          @totp_form = TotpChallengeForm.new(totp_params)
          return render :new, status: :unprocessable_content unless @totp_form.valid?

          user = mfa_user
          last_otp_at, totp_record = verify_totp_for(user, @totp_form.token)

          if last_otp_at
            handle_totp_success(user, totp_record, last_otp_at)
          else
            handle_totp_failure(user)
          end
        end

        def handle_totp_success(user, totp_record, last_otp_at)
          totp_record&.update!(last_otp_at: Time.zone.at(last_otp_at))

          Rails.event.notify(
            "authentication.totp.succeeded",
            user_id: user.id,
            ip_address: request.remote_ip,
          )

          clear_mfa_session!
          result = log_in(user, require_totp_check: false)
          if result[:status] == :session_limit_hard_reject
            render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
          elsif result[:restricted]
            redirect_to sign_app_in_session_path, notice: I18n.t("sign.app.in.session.restricted_notice")
          else
            issue_checkpoint!
            redirect_to sign_app_in_checkpoint_path(ri: params[:ri]),
                        notice: t("sign.app.authentication.totp.success")
          end
        end

        def handle_totp_failure(user)
          Rails.event.notify(
            "authentication.totp.failed",
            user_id: user&.id,
            ip_address: request.remote_ip,
          )
          @totp_form.errors.add(:token, t("sign.app.authentication.totp.invalid"))
          @secret_hints = active_secret_hints_for(user)
          render :new, status: :unprocessable_content
        end

        private

        def ensure_mfa_user!
          return if mfa_user

          redirect_to new_sign_app_in_path, status: :see_other
        end

        def mfa_user
          return @mfa_user if defined?(@mfa_user)

          user_id = session[MFA_USER_SESSION_KEY]
          return @mfa_user = nil if user_id.blank?

          @mfa_user = User.find_by(id: user_id)
        end

        def clear_mfa_session!
          session[MFA_USER_SESSION_KEY] = nil
        end

        def verify_totp_for(user, token)
          user.active_totps.order(created_at: :desc).each do |totp|
            last_otp_at = ROTP::TOTP.new(totp.private_key).verify(token.to_s)
            return [last_otp_at, totp] if last_otp_at
          end
          [nil, nil]
        end

        def active_secret_hints_for(user)
          user.user_secrets
            .where(user_identity_secret_status_id: UserSecretStatus::ACTIVE)
            .order(created_at: :desc)
            .limit(10)
            .map { |s| s.name.to_s.first(4) }
        end

        def totp_params
          params.fetch(:totp_challenge_form, {}).permit(:token)
        end
      end
    end
  end
end
