# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class SecretsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_secret, only: %i[show edit destroy]

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
          # Require acknowledgement checkbox
          unless params[:acknowledged] == "1"
            @secret = current_user.user_secrets.new
            @secret.errors.add(:base, I18n.t("sign.app.configuration.secrets.errors.acknowledgement_required"))
            @raw_secret = session[:user_secret_raw] || UserSecret.generate_raw_secret
            session[:user_secret_raw] = @raw_secret
            render :new, status: :unprocessable_content
            return
          end

          raw_secret = session.delete(:user_secret_raw)
          result = UserSecrets::Create.call(
            actor: current_user,
            user: current_user,
            params: {}, # Don't pass any params - service handles everything
            raw_secret: raw_secret,
          )

          session[:last_issued_secret] = {
            prefix: result.secret.name,
            raw_secret: result.raw_secret
          }

          redirect_to sign_app_configuration_secrets_path, status: :see_other
        rescue ActiveRecord::RecordInvalid => e
          @secret = e.record
          @raw_secret = raw_secret.presence || UserSecret.generate_raw_secret
          session[:user_secret_raw] = @raw_secret
          render :new, status: :unprocessable_content
        end

        def destroy
          UserSecrets::Destroy.call(actor: current_user, secret: @secret)
          redirect_to sign_app_configuration_secrets_path, status: :see_other
        end

        private

          def set_secret
            @secret = current_user.user_secrets.find(params[:id])
          end

          def secret_params
            # Empty params - we don't accept any user input for secret creation
            # Name is auto-generated from secret prefix
            # Kind is always UNLIMITED
            # Status is always ACTIVE
            {}
          end
      end
    end
  end
end
