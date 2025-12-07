# frozen_string_literal: true

module Apex
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::DefaultUrlOptions
      include ::QueryCanonicalizer
      include ::Apex::Concerns::Regionalization

      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      before_action :set_locale
      before_action :set_timezone

      protected

      def logged_in_user?
        false
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
