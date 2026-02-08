# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class SecretsController < ApplicationController
        include ::Auth::StepUp

        before_action :authenticate_user!
        before_action :set_secret, only: %i(show edit update destroy)
        before_action -> { require_step_up!(scope: "configuration_secret") }, only: %i(update destroy)
        before_action :ensure_verified_recovery_identity_for_registration!, only: [:new]

        def index
          @secrets = current_user.user_secrets.order(created_at: :desc)
        end

        def show
        end

        def new
          @secret = current_user.user_secrets.new
          @raw_secret = UserSecret.generate_raw_secret
          session[:user_secret_raw] = @raw_secret
          @secret.name = @raw_secret.first(4)
        end

        def edit
        end

        def create
          raw_secret = session.delete(:user_secret_raw)
          UserSecrets::Create.call(
            actor: current_user,
            user: current_user,
            params: secret_params,
            raw_secret: raw_secret,
          )

          flash[:notice] = t(".created")
          redirect_to sign_app_configuration_secrets_path
        rescue ActiveRecord::RecordInvalid => e
          render plain: e.record.errors.full_messages.join("\n"), status: :unprocessable_entity
        end

        def update
          if disabling_secret? && AuthMethodGuard.last_method?(current_user, excluding: @secret)
            flash[:alert] = t(".last_method")
            return redirect_to sign_app_configuration_secrets_path
          end

          UserSecrets::Update.call(
            actor: current_user,
            secret: @secret,
            params: secret_params,
          )

          flash[:notice] = t(".updated")
          redirect_to sign_app_configuration_secrets_path
        rescue ActiveRecord::RecordInvalid => e
          @secret = e.record.is_a?(UserSecret) ? e.record : @secret
          render :edit, status: :unprocessable_content
        end

        def destroy
          if AuthMethodGuard.last_method?(current_user, excluding: @secret)
            flash[:alert] = t(".last_method")
            return redirect_to sign_app_configuration_secrets_path
          end

          UserSecrets::Destroy.call(actor: current_user, secret: @secret)
          flash[:notice] = t(".destroyed")
          redirect_to sign_app_configuration_secrets_path, status: :see_other
        end

        private

        def set_secret
          @secret = current_user.user_secrets.find_by!(public_id: params[:public_id])
        end

        def secret_params
          params.fetch(:user_secret, {}).permit(:name, :enabled)
        end

        def disabling_secret?
          params[:user_secret].present? &&
            params[:user_secret].key?(:enabled) &&
            ActiveModel::Type::Boolean.new.cast(params[:user_secret][:enabled]) == false
        end

        def ensure_verified_recovery_identity_for_registration!
          return if current_user.has_verified_recovery_identity?

          render plain: User::RECOVERY_IDENTITY_REQUIRED_MESSAGE, status: :forbidden
        end
      end
    end
  end
end
