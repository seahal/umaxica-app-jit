# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::Authn
      include ::RateLimit
      include ::DefaultUrlOptions
      include Pundit::Authorization
      include ::Authentication::User

      protect_from_forgery with: :exception
      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      def user_not_authorized
        respond_to do |format|
          format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
          format.any { head :forbidden }
        end
      end

      # Minimal authentication guard for namespaced sign app views.
      # Uses `logged_in?` provided by Authn concern (cookie-based JWT check).
      def authenticate_user!
        return if logged_in?

        # Halt the request with 401 for both HTML and JSON.
        if request.format.json?
          render json: { error: "Unauthorized" }, status: :unauthorized
          nil
        else
          head :unauthorized
          nil
        end
      end
    end
  end
end
