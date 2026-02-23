# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class ChallengesController < ApplicationController
        include ::Verification::User

        before_action :authenticate_user!

        def show
          @user = current_user
          @passkeys = current_user.user_passkeys.active.order(created_at: :desc)
          @totps =
            current_user.user_one_time_passwords
              .where(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
              .order(created_at: :desc)
          @secrets =
            current_user.user_secrets
              .where(user_identity_secret_status_id: UserSecretStatus::ACTIVE)
              .order(created_at: :desc)
        end

        def update
          enabled = ActiveModel::Type::Boolean.new.cast(params.dig(:user, :multi_factor_enabled))
          current_user.update!(multi_factor_enabled: enabled)

          redirect_to sign_app_configuration_challenge_path,
                      notice: t("sign.app.configuration.mfa.update.success")
        rescue ActiveRecord::RecordInvalid
          show
          flash.now[:alert] = t("sign.app.configuration.mfa.update.failure")
          render :show, status: :unprocessable_content
        end

        private

        def verification_required_action?
          action_name == "update"
        end

        def verification_scope
          "configuration_mfa"
        end
      end
    end
  end
end
