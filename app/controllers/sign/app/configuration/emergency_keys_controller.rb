# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class EmergencyKeysController < ApplicationController
        before_action :authenticate_user!

        def show
          @raw_secret = session.delete(:recovery_secret_raw)

          return if @raw_secret.present?

          redirect_to sign_app_configuration_path,
                      alert: t("sign.app.configuration.emergency_key.missing")
        end
      end
    end
  end
end
