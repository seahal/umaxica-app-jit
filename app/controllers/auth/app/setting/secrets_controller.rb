# frozen_string_literal: true

module Auth
  module App
    module Setting
      class SecretsController < ApplicationController
        include Auth::Setting::Secrets

        def index
          super
          normalize_last_used_at(@secrets)
        end

        def show
          super
          normalize_last_used_at(@secret)
        end

        private

        def authenticate_identity!
          authenticate_user!
        end

        def secret_scope
          current_user.user_identity_secrets
        end

        def secret_param_key
          :user_identity_secret
        end

        def secrets_index_path
          auth_app_setting_secrets_path
        end

        def secret_path(secret)
          auth_app_setting_secret_path(secret)
        end

        def normalize_last_used_at(secrets)
          Array(secrets).each do |secret|
            next unless secret.last_used_at.is_a?(Float) && secret.last_used_at.infinite? == -1

            secret.last_used_at = nil
          end
        end
      end
    end
  end
end
