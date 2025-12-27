# frozen_string_literal: true

module Help
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit

      protect_from_forgery with: :exception
      include ::DefaultUrlOptions

      protect_from_forgery with: :exception
      include Pundit::Authorization

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
    end
  end
end
