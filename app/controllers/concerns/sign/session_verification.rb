# frozen_string_literal: true

module Sign
  # Concern for session presence verification
  # Provides methods to verify session existence before allowing access
  #
  # Usage:
  #   class OutsController < ApplicationController
  #     include Sign::SessionVerification
  #     before_action :verify_session_user
  #   end
  module SessionVerification
    extend ActiveSupport::Concern

    # Verifies that a specific session key exists
    # Raises ActionController::RoutingError if session is blank
    #
    # @param session_key [Symbol, String] The session key to verify
    # @param error_message [String] Optional custom error message
    # @raise [ActionController::RoutingError] if session key is blank
    #
    # @example
    #   verify_session_presence(:user)
    def verify_session_presence(session_key, error_message: "Not Found")
      raise ActionController::RoutingError, error_message if session[session_key].blank?
    end

    # Verifies user session exists
    # Raises ActionController::RoutingError if user session is blank
    #
    # @example
    #   before_action :verify_session_user
    def verify_session_user
      verify_session_presence(:user)
    end

    # Verifies staff session exists
    # Raises ActionController::RoutingError if staff session is blank
    #
    # @example
    #   before_action :verify_session_staff
    def verify_session_staff
      verify_session_presence(:staff)
    end
  end
end
