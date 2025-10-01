# frozen_string_literal: true

module Auth
  module App
    class ApplicationController < ActionController::Base
      include ::Authn
      include Pundit::Authorization

      allow_browser versions: :modern



      # Built-in Rails' rate limiting API
      RATE_LIMIT_STORE = ActiveSupport::Cache::RedisCacheStore.new(url: Rails.application.credentials.dig(:REDIS, :REDIS_RACK_ATTACK_URL))
      rate_limit to: 1000, within: 1.hour, store: RATE_LIMIT_STORE

      private

      # Minimal authentication guard for namespaced auth app controllers.
      # Uses `logged_in?` provided by Authn concern (cookie-based JWT check).
      def authenticate_user!
        return if logged_in?

        # Halt the request with 401 for both HTML and JSON.
        respond_to do |format|
          format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
          format.any  { head :unauthorized }
        end
      end
    end
  end
end
