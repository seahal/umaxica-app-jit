# frozen_string_literal: true

module Auth
  # Concern for managing authentication session state
  # Provides methods for storing, loading, and validating authentication sessions
  #
  # Usage:
  #   class MyController < ApplicationController
  #     include Auth::SessionAuthentication
  #   end
  module SessionAuthentication
    extend ActiveSupport::Concern

    # Loads authentication session data and validates expiry
    # Returns the found record or handles redirect on expiry
    #
    # @param session_key [Symbol, String] The session key to load from (e.g., :user_email_authentication_id)
    # @param model_class [Class] The model class to load (e.g., UserEmail)
    # @param redirect_path [String, Symbol] Where to redirect on session expiry
    # @param redirect_message [String] The translation key for expiry message
    # @param block [Proc] Optional block for additional validation
    # @return [ActiveRecord::Base, nil] The loaded record or nil
    #
    # @example
    #   def load_user_email
    #     load_authentication_session(
    #       :user_email_authentication_id,
    #       UserEmail,
    #       new_sign_app_in_email_path,
    #       "sign.app.authentication.email.edit.session_expired"
    #     ) do |user_email|
    #       user_email.present? && !user_email.otp_expired?
    #     end
    #   end
    def load_authentication_session(session_key, model_class, redirect_path, redirect_message)
      record = nil

      if session[session_key].present?
        record = model_class.find_by(id: session[session_key])

        # If block provided, use it for validation; otherwise just check presence
        is_valid =
          if block_given?
            yield(record)
          else
            record.present?
          end

        return record if is_valid

        # Session expired or invalid
        handle_session_expiry(redirect_path, redirect_message)
        nil
      else
        # No session data
        handle_session_expiry(redirect_path, redirect_message)
        nil
      end
    end

    # Stores authentication session data
    #
    # @param session_key [Symbol, String] The session key to store to
    # @param value [Object] The value to store (typically an ID or hash)
    #
    # @example
    #   store_authentication_session(:user_email_authentication_id, user_email.id)
    def store_authentication_session(session_key, value)
      session[session_key] = value
    end

    # Clears authentication session data
    #
    # @param session_keys [Array<Symbol, String>] The session keys to clear
    #
    # @example
    #   clear_authentication_session(:user_email_authentication_id, :user_email_authentication_rd)
    def clear_authentication_session(*session_keys)
      session_keys.each do |key|
        session[key] = nil
      end
    end

    # Validates session expiry against a timestamp
    #
    # @param session_data [Hash] The session data containing expiry information
    # @param expiry_key [String, Symbol] The key in session_data that contains expiry timestamp
    # @return [Boolean] true if not expired, false otherwise
    #
    # @example
    #   valid = validate_session_expiry(session[:user_telephone_registration], "expires_at")
    def validate_session_expiry(session_data, expiry_key = "expires_at")
      return false if session_data.blank?
      return true unless session_data[expiry_key]

      session_data[expiry_key].to_i > Time.now.to_i
    end

    # Loads a record from session with additional validation
    # Similar to load_authentication_session but with more flexible validation options
    #
    # @param session_key [Symbol, String] The session key containing the record ID
    # @param model_class [Class] The model class to load
    # @param validations [Hash] Additional validations to perform
    # @option validations [Proc] :custom Custom validation block
    # @option validations [Boolean] :check_otp_expiry Check OTP expiry (default: false)
    # @option validations [String] :status_id Required status_id value
    # @return [ActiveRecord::Base, nil] The loaded record or nil
    #
    # @example
    #   load_session_record(
    #     :user_email_authentication_id,
    #     UserEmail,
    #     check_otp_expiry: true,
    #     status_id: "UNVERIFIED_WITH_SIGN_UP"
    #   )
    def load_session_record(session_key, model_class, validations = {})
      return nil if session[session_key].blank?

      record = model_class.find_by(id: session[session_key])
      return nil if record.blank?

      # Check OTP expiry if requested
      if validations[:check_otp_expiry] && record.respond_to?(:otp_expired?)
        return nil if record.otp_expired?
      end

      # Check status_id if provided
      if validations[:status_id] && record.respond_to?(:user_email_status_id)
        return nil if record.user_email_status_id != validations[:status_id]
      end

      # Run custom validation if provided
      if validations[:custom]
        return nil unless validations[:custom].call(record)
      end

      record
    end

    private

    # Handles session expiry by redirecting with appropriate message
    #
    # @param redirect_path [String, Symbol] Where to redirect
    # @param message_key [String] Translation key for the expiry message
    def handle_session_expiry(redirect_path, message_key)
      redirect_params = { notice: t(message_key) }
      # Preserve redirect parameter if present
      redirect_params[:rd] = session[:user_email_authentication_rd] if session[:user_email_authentication_rd].present?
      redirect_to redirect_path, redirect_params
    end
  end
end
