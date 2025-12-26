# frozen_string_literal: true

module Auth
  module Org
    module Setting
      class SecretsController < ApplicationController
        include Auth::Setting::Secrets

        private

        def authenticate_identity!
          authenticate_staff!
        end

        def secret_scope
          current_staff.staff_identity_secrets
        end

        def secret_param_key
          :staff_identity_secret
        end

        def secrets_index_path
          auth_org_setting_secrets_path
        end

        def secret_path(secret)
          auth_org_setting_secret_path(secret)
        end
      end
    end
  end
end
