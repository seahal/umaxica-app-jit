# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::User
      include ::RestrictedSessionGuard
      include ::Sign::ErrorResponses
      include Pundit::Authorization

      protect_from_forgery with: :exception

      rescue_from ActionController::InvalidCrossOriginRequest, with: :handle_csrf_failure

      allow_browser versions: :modern

      guest_only!

      # Note: set_locale and set_timezone are already defined in Preference::Global
      prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      private

      def handle_csrf_failure
        if request.format.json?
          render json: { error: I18n.t("errors.invalid_authenticity_token", default: "セッションが期限切れです。ページを再読み込みしてください。") },
                 status: :unprocessable_content
        else
          raise ActionController::InvalidCrossOriginRequest
        end
      end

      # Redirect logged-in users from guest_only! pages to the configuration page
      def after_login_path
        # Preserve the ri parameter
        redirect_params = {}
        redirect_params[:ri] = params[:ri] if params[:ri].present?

        # Redirect to the configuration page
        sign_app_configuration_path(redirect_params)
      rescue StandardError
        # On error, keep the ri parameter and fall back to the root path
        params[:ri].present? ? "/?ri=#{params[:ri]}" : "/"
      end
    end
  end
end
