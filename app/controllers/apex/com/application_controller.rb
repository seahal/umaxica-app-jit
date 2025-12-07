# frozen_string_literal: true

module Apex
  module Com
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::DefaultUrlOptions
      include ::Apex::Concerns::Regionalization

      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      before_action :set_locale
      before_action :set_timezone

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
