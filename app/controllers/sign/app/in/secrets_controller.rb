# frozen_string_literal: true

module Sign
  module App
    module In
      class SecretsController < ApplicationController
        include CloudflareTurnstile
        include Common::Redirect
        include SessionLimitGate

        class SecretLoginForm
          include ActiveModel::Model

          attr_accessor :account_identifiable_information, :secret_value

          validates :account_identifiable_information, presence: true
          # rubocop:disable I18n/RailsI18n/DecorateStringFormattingUsingInterpolation
          validates :secret_value,
                    presence: true,
                    length: {
                      is: Secret::SECRET_PASSWORD_LENGTH,
                      message: I18n.t("sign.app.authentication.secret.new.secret_length",
                                      default: "シークレットは#{Secret::SECRET_PASSWORD_LENGTH}文字で入力してください")
                    }
          # rubocop:enable I18n/RailsI18n/DecorateStringFormattingUsingInterpolation
          def self.model_name
            ActiveModel::Name.new(self, nil, "secret_login_form")
          end
        end

        class MfaSecretForm
          include ActiveModel::Model

          attr_accessor :secret_value

          validates :secret_value, presence: true

          def self.model_name
            ActiveModel::Name.new(self, nil, "mfa_secret_form")
          end
        end

        MFA_USER_SESSION_KEY = :mfa_user_id

        before_action :reject_logged_in_session

        def new
          if mfa_user
            @secret_form = MfaSecretForm.new
            @secret_hints = active_secret_hints_for(mfa_user)
          else
            @secret_form = SecretLoginForm.new
          end
        end

        def create
          if mfa_user
            handle_mfa_login
          else
            handle_standard_login
          end
        end

        def handle_mfa_login
          @secret_form = MfaSecretForm.new(mfa_secret_params)
          return render :new, status: :unprocessable_content unless @secret_form.valid?

          user = mfa_user
          secret = verify_and_consume_secret(user, @secret_form.secret_value)

          if secret
            handle_successful_mfa(user, secret)
          else
            handle_failed_mfa(user)
          end
        end

        def handle_standard_login
          @secret_form = SecretLoginForm.new(secret_params)
          return render :new, status: :unprocessable_content unless @secret_form.valid?

          return render :new, status: :unprocessable_content unless validate_turnstile!(@secret_form)

          user = find_user_by_info(@secret_form.account_identifiable_information)
          secret = user ? verify_and_consume_secret(user, @secret_form.secret_value) : nil

          if user && secret
            process_standard_login(user)
          else
            handle_failed_standard_login
          end
        end

        def handle_successful_mfa(user, secret)
          Rails.event.notify(
            "authentication.totp.succeeded", user_id: user.id, ip_address: request.remote_ip,
                                             method: "secret", secret_id: secret.id,
          )
          clear_mfa_session!
          result = log_in(user, require_totp_check: false)
          if result[:status] == :session_limit_exceeded || result[:status] == :session_limit_pending
            issue_session_limit_gate!(return_to: request.fullpath, flow: "in.session")
            redirect_to edit_sign_app_in_session_path
          else
            redirect_with_notice(sign_app_configuration_path, t("sign.app.authentication.secret.create.success"))
          end
        end

        def handle_failed_mfa(user)
          Rails.event.notify(
            "authentication.totp.failed", user_id: user.id, ip_address: request.remote_ip,
                                          method: "secret",
          )
          @secret_form.errors.add(:secret_value, t("sign.app.authentication.secret.create.invalid"))
          @secret_hints = active_secret_hints_for(user)
          render :new, status: :unprocessable_content
        end

        def find_user_by_info(info)
          UserEmail.find_by(address: info)&.user ||
            UserTelephone.find_by(number: info)&.user
        end

        def process_standard_login(user)
          result = log_in(user, require_totp_check: true)
          if result[:status] == :totp_required
            redirect_to new_sign_app_in_totp_path, notice: t("sign.app.authentication.totp.required")
          elsif result[:status] == :session_limit_exceeded || result[:status] == :session_limit_pending
            issue_session_limit_gate!(return_to: request.fullpath, flow: "in.session")
            redirect_to edit_sign_app_in_session_path
          else
            redirect_with_notice(sign_app_configuration_path, t("sign.app.authentication.secret.create.success"))
          end
        end

        def handle_failed_standard_login
          @secret_form.errors.add(:secret_value, t("sign.app.authentication.secret.create.invalid"))
          render :new, status: :unprocessable_content
        end

        def validate_turnstile!(form)
          validation = cloudflare_turnstile_validation
          return true if validation["success"]

          form.errors.add(:base, t("sign.app.authentication.secret.new.turnstile_validation_failed"))
          false
        end

        private

          def mfa_user
            return @mfa_user if defined?(@mfa_user)

            @mfa_user = User.find_by(id: session[MFA_USER_SESSION_KEY])
          end

          def clear_mfa_session!
            session[MFA_USER_SESSION_KEY] = nil
          end

          def verify_and_consume_secret(user, raw_secret)
            user.user_secrets
                .where(user_identity_secret_status_id: UserSecretStatus::ACTIVE)
                .order(created_at: :desc)
                .find { |s| s.verify_and_consume!(raw_secret.to_s) }
          end

          def active_secret_hints_for(user)
            user.user_secrets
                .where(user_identity_secret_status_id: UserSecretStatus::ACTIVE)
                .order(created_at: :desc)
                .limit(10)
                .map { |s| s.name.to_s.first(4) }
          end

          def secret_params
            params.fetch(:secret_login_form, {}).permit(
              :account_identifiable_information,
              :secret_value,
            )
          end

          def mfa_secret_params
            params.fetch(:mfa_secret_form, {}).permit(:secret_value)
          end
      end
    end
  end
end
