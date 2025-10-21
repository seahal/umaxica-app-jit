# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::Authn
      include ::RateLimit
      include ::DefaultUrlOptions
      include Pundit::Authorization

      allow_browser versions: :modern

      private

      # Minimal authentication guard for namespaced sign app controllers.
      # Uses `logged_in?` provided by Authn concern (cookie-based JWT check).
      def authenticate_user!
        return if logged_in?

        # Halt the request with 401 for both HTML and JSON.
        respond_to do |format|
          format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
          format.any { head :unauthorized }
        end
      end
    end
  end
end
