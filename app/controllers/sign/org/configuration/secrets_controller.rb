# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class SecretsController < ApplicationController
        include Sign::Setting::Secrets

        private

        def authenticate_identity!
          authenticate_staff!
        end

        def secret_scope
          current_staff.staff_secrets
        end

        def secret_param_key
          :staff_secret
        end

        def secrets_index_path
          sign_org_configuration_secrets_path
        end

        def secret_path(secret)
          sign_org_configuration_secret_path(secret)
        end
      end
    end
  end
end
