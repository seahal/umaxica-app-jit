module Auth
  module App
    module Setting
      class SecretsController < ApplicationController
        include Auth::Setting::Secrets

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
      end
    end
  end
end
