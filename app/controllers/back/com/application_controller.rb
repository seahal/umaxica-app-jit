# frozen_string_literal: true

module Back
  module Com
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include Authn

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
