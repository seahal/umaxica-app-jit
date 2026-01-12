# frozen_string_literal: true

module Sign
  # Concern for handling redirect parameters (rd) across authentication flows
  # Manages the rd parameter which stores Base64-encoded redirect URLs
  #
  # Usage:
  #   class MyController < ApplicationController
  #     include Sign::RedirectParameterHandling
  #   end
  module RedirectParameterHandling
    extend ActiveSupport::Concern

    # Default session key for storing redirect parameter
    DEFAULT_RD_SESSION_KEY = :user_email_authentication_rd

    # Preserves the redirect parameter in session and returns it for immediate use
    #
    # @param session_key [Symbol] The session key to store rd parameter in
    # @return [String, nil] The rd parameter value if present
    #
    # @example
    #   def create
    #     preserve_redirect_parameter
    #     # session[:user_email_authentication_rd] is now set if params[:rd] was present
    #   end
    def preserve_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      if params[:rd].present?
        session[session_key] = params[:rd]
        params[:rd]
      end
    end

    # Retrieves and clears the redirect parameter from session
    # Falls back to params[:rd] if session is empty
    #
    # @param session_key [Symbol] The session key to retrieve from
    # @return [String, nil] The rd parameter value
    #
    # @example
    #   def update
    #     rd_param = retrieve_redirect_parameter
    #     # rd_param contains the redirect URL (from params or session)
    #     # session is now cleared
    #   end
    def retrieve_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      rd_param = params[:rd].presence || session[session_key]
      session[session_key] = nil
      rd_param
    end

    # Retrieves redirect parameter without clearing session
    #
    # @param session_key [Symbol] The session key to retrieve from
    # @return [String, nil] The rd parameter value
    def peek_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      params[:rd].presence || session[session_key]
    end

    # Builds redirect params hash with optional rd parameter
    # Automatically includes rd from params or session if present
    #
    # @param message_key [Symbol] Either :notice or :alert
    # @param message_value [String] The message text or translation key result
    # @param session_key [Symbol] The session key to check for rd parameter
    # @return [Hash] Redirect params hash
    #
    # @example
    #   redirect_params = build_redirect_params(:notice, t("success"))
    #   # => { notice: "Success message", rd: "encoded_url" }
    #   redirect_to some_path(redirect_params)
    def build_redirect_params(message_key, message_value, session_key = DEFAULT_RD_SESSION_KEY)
      redirect_params = { message_key => message_value }
      rd_value = peek_redirect_parameter(session_key)
      redirect_params[:rd] = rd_value if rd_value.present?
      redirect_params
    end

    # Builds redirect params hash with notice message
    #
    # @param message_value [String] The notice message
    # @param session_key [Symbol] The session key to check for rd parameter
    # @return [Hash] Redirect params with notice
    def build_notice_params(message_value, session_key = DEFAULT_RD_SESSION_KEY)
      build_redirect_params(:notice, message_value, session_key)
    end

    # Builds redirect params hash with alert message
    #
    # @param message_value [String] The alert message
    # @param session_key [Symbol] The session key to check for rd parameter
    # @return [Hash] Redirect params with alert
    def build_alert_params(message_value, session_key = DEFAULT_RD_SESSION_KEY)
      build_redirect_params(:alert, message_value, session_key)
    end

    # Performs redirect with rd parameter handling
    # Either redirects to encoded rd URL or falls back to default path
    #
    # @param default_path [String] Default path if no rd parameter
    # @param message_key [Symbol] Either :notice or :alert
    # @param message_value [String] Flash message value
    # @param session_key [Symbol] The session key for rd parameter
    #
    # @example
    #   def update
    #     if success
    #       redirect_with_rd_handling("/", :notice, t("success"))
    #     end
    #   end
    def redirect_with_rd_handling(default_path, message_key, message_value, session_key = DEFAULT_RD_SESSION_KEY)
      rd_param = retrieve_redirect_parameter(session_key)

      if rd_param.present?
        flash[message_key] = message_value
        jump_to_generated_url(rd_param, fallback: default_path)
      else
        redirect_to default_path, message_key => message_value
      end
    end

    # Performs redirect with notice message and rd handling
    #
    # @param default_path [String] Default path if no rd parameter
    # @param message_value [String] Notice message value
    # @param session_key [Symbol] The session key for rd parameter
    def redirect_with_notice(default_path, message_value, session_key = DEFAULT_RD_SESSION_KEY)
      redirect_with_rd_handling(default_path, :notice, message_value, session_key)
    end

    # Performs redirect with alert message and rd handling
    #
    # @param default_path [String] Default path if no rd parameter
    # @param message_value [String] Alert message value
    # @param session_key [Symbol] The session key for rd parameter
    def redirect_with_alert(default_path, message_value, session_key = DEFAULT_RD_SESSION_KEY)
      redirect_with_rd_handling(default_path, :alert, message_value, session_key)
    end

    # Adds rd parameter to existing redirect params if present
    # Modifies the hash in place
    #
    # @param redirect_params [Hash] The redirect params hash to modify
    # @param session_key [Symbol] The session key to check for rd parameter
    # @return [Hash] The modified redirect_params hash
    #
    # @example
    #   redirect_params = { notice: "Success" }
    #   add_rd_to_params!(redirect_params)
    #   # redirect_params now includes :rd if present
    def add_rd_to_params!(redirect_params, session_key = DEFAULT_RD_SESSION_KEY)
      rd_value = peek_redirect_parameter(session_key)
      redirect_params[:rd] = rd_value if rd_value.present?
      redirect_params
    end
  end
end
