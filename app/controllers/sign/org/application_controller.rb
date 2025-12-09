# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include ::Authn
      include Pundit::Authorization
      include ::DefaultUrlOptions
      include ::RateLimit

      allow_browser versions: :modern

      rescue_from Pundit::NotAuthorizedError, with: :staff_not_authorized

      helper_method :logged_in?, :logged_in_staff?, :logged_in_user?

      protected

      def staff_not_authorized
        respond_to do |format|
          format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
          format.any { head :forbidden }
        end
      end

      def logged_in_staff?
        current_staff.present?
      end

      def logged_in_user?
        # TODO: Implement staff-side end-user sessions
        false
      end

      def logged_in?
        logged_in_staff? || logged_in_user?
      end

      def authenticate_staff!
        return if logged_in_staff?

        if request.format.json?
          render json: { error: "Unauthorized" }, status: :unauthorized
        else
          head :unauthorized
        end
        nil
      end
    end
  end
end
