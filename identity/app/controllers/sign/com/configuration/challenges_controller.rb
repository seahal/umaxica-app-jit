# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class ChallengesController < ApplicationController
        auth_required!

        include ::Verification::User

        before_action :authenticate_customer!

        def show
          @user = current_customer
          @passkeys = current_customer.customer_passkeys.active.order(created_at: :desc)
          @totps = []
          @secrets =
            current_customer.customer_secrets
              .where(customer_secret_status_id: CustomerSecretStatus::ACTIVE)
              .order(created_at: :desc)
        end

        def update
          enabled = ActiveModel::Type::Boolean.new.cast(params.dig(:user, :multi_factor_enabled))
          current_customer.update!(multi_factor_enabled: enabled)

          redirect_to(
            identity.sign_com_configuration_challenge_path(ri: params[:ri]),
            notice: t("sign.app.configuration.mfa.update.success"),
          )
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
