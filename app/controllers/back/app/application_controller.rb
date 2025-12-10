# frozen_string_literal: true

module Back
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization

      protect_from_forgery with: :exception
      include ::RateLimit

      protect_from_forgery with: :exception
      include ::DefaultUrlOptions

      protect_from_forgery with: :exception
      include ::Back::Concerns::Regionalization

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      before_action :set_locale
      before_action :set_timezone

      protected

      def user_not_authorized
        respond_to do |format|
          format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
          format.any { head :forbidden }
        end
      end

      def logged_in_user?
        false
      end
    end
  end
end
