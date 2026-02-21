# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class GooglesController < ApplicationController
        include ::Verification::User

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "social_unlink") }, only: :destroy

        def show
        end

        def destroy
          SocialAuthService.unlink(provider: "google_oauth2", user: current_user)
          redirect_to sign_app_configuration_google_path,
                      notice: I18n.t("sign.app.social.sessions.destroy.success", provider: "Google")
        rescue SocialAuth::LastIdentityError
          redirect_to sign_app_configuration_google_path,
                      alert: I18n.t("errors.social_auth.insufficient_login_methods")
        end
      end
    end
  end
end
