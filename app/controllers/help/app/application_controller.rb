# frozen_string_literal: true

module Help
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Main
      include ::Preference::Regional
      include Pundit::Authorization

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      def get_language
        "ja"
      end

      private

      def user_not_authorized
        respond_to do |format|
          format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
          format.any { head :forbidden }
        end
      end
    end
  end
end
