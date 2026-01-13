# frozen_string_literal: true

module Apex
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::Preference::Global
      include ::Sign::ErrorResponses
      include ::Authentication::User

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      helper_method :logged_in_user?, :logged_in? if respond_to?(:helper_method)

      private

      def logged_in_user?
        logged_in?
      end

      def user_not_authorized
        respond_to do |format|
          format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
          format.any { head :forbidden }
        end
      end
    end
  end
end
