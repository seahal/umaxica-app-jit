# typed: false
# frozen_string_literal: true

module Sign
  # Concern for standardized error response handling
  # Provides common error handlers for Pundit authorization failures
  #
  # Usage:
  #   class ApplicationController < ActionController::Base
  #     include Sign::ErrorResponses
  #     rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized
  #   end
  module ErrorResponses
    extend ActiveSupport::Concern

    included do
      include Common::Redirect

      # Automatically set up rescue_from if Pundit is included
      if respond_to?(:rescue_from)
        rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized if defined?(Pundit)
        rescue_from ApplicationError, with: :handle_application_error
        rescue_from ActionController::InvalidCrossOriginRequest, with: :handle_csrf_failure
      end
    end

    def handle_application_error(exception)
      respond_to do |format|
        format.html do
          flash[:alert] = exception.message
          safe_redirect_back_or_to("/")
        end
        format.json { render json: { error: exception.message }, status: exception.status_code }
        format.any { head exception.status_code }
      end
    end

    # Handles Pundit authorization failures
    # Responds with JSON error for API requests, forbidden status for others
    #
    # @param exception [Pundit::NotAuthorizedError] The authorization error
    def handle_not_authorized(_exception = nil)
      respond_to do |format|
        format.json { render json: { error: I18n.t("errors.forbidden") }, status: :forbidden }
        format.any { head :forbidden }
      end
    end

    # Alias for user-facing authorization failures
    alias_method :user_not_authorized, :handle_not_authorized

    # Alias for staff-facing authorization failures
    alias_method :staff_not_authorized, :handle_not_authorized

    def handle_csrf_failure
      if request.format.json?
        render json: { error: I18n.t("errors.invalid_authenticity_token", default: "セッションが期限切れです。ページを再読み込みしてください。") },
               status: :unprocessable_content
      else
        raise ActionController::InvalidCrossOriginRequest
      end
    end
  end
end
