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
      # Automatically set up rescue_from if Pundit is included
      rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized if defined?(Pundit)
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
  end
end
