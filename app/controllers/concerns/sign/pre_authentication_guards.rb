# frozen_string_literal: true

module Sign
  # Concern for pre-authentication guards
  # Provides methods to ensure users are not already logged in before authentication/registration
  #
  # Usage:
  #   class MyController < ApplicationController
  #     include Sign::PreAuthenticationGuards
  #     before_action :ensure_not_logged_in
  #   end
  module PreAuthenticationGuards
    extend ActiveSupport::Concern

    # Ensures user is not already logged in
    # Renders bad_request with message if user is logged in
    # Used for authentication endpoints (login)
    #
    # @param message_key [String] Optional translation key for the error message
    # @return [nil] Returns nil if user is logged in (stops filter chain)
    #
    # @example
    #   before_action :ensure_not_logged_in
    def ensure_not_logged_in(message_key: nil)
      if logged_in?
        message = message_key ? t(message_key) : t("sign.app.authentication.email.new.you_have_already_logged_in")
        render plain: message, status: :bad_request
        nil
      end
    end

    # Ensures user is not already logged in (registration variant)
    # Redirects to root with alert message if user is logged in
    # Used for registration endpoints
    #
    # @param redirect_path [String] Path to redirect to (default: "/")
    # @param message_key [String] Optional translation key for the alert message
    #
    # @example
    #   before_action :ensure_not_logged_in_for_registration
    def ensure_not_logged_in_for_registration(redirect_path: "/", message_key: nil)
      if logged_in?
        message = message_key ? t(message_key) : t("sign.app.registration.email.already_logged_in")
        redirect_to redirect_path, alert: message
      end
    end

    # Checks if user is logged in and renders error if so (inline variant)
    # Returns true if user is logged in, false otherwise
    # Useful for inline checks in actions
    #
    # @param message_key [String] Translation key for the error message
    # @return [Boolean] true if user is logged in, false otherwise
    #
    # @example
    #   def create
    #     return if reject_if_logged_in("sign.app.authentication.telephone.create.you_have_already_logged_in")
    #     # ... continue with action
    #   end
    def reject_if_logged_in(message_key)
      if logged_in?
        render plain: t(message_key), status: :bad_request
        true
      else
        false
      end
    end
  end
end
