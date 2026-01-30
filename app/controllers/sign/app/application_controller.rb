# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::User
      include Pundit::Authorization
      include Sign::ErrorResponses

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      guest_only!

      # Note: set_locale and set_timezone are already defined in Preference::Global
      prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      private

      # Redirect logged-in users from guest_only! pages to the configuration page
      def after_login_path
        # Preserve the ri parameter
        redirect_params = {}
        redirect_params[:ri] = params[:ri] if params[:ri].present?

        # Redirect to the configuration page
        sign_app_configuration_path(redirect_params)
      rescue StandardError => e
        # On error, keep the ri parameter and fall back to the root path
        Rails.logger.warn("after_login_path error: #{e.message}")
        params[:ri].present? ? "/?ri=#{params[:ri]}" : "/"
      end
    end
  end
end
