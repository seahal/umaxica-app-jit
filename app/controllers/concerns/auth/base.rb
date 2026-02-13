# frozen_string_literal: true

require "jwt"

module Auth
  module Base
    extend ActiveSupport::Concern
    include Common::Redirect

    # --- Policy errors ---
    class MissingPolicyError < StandardError; end

    class InvalidPolicyError < StandardError; end

    class SkipNotAllowedError < StandardError; end

    VALID_POLICIES = %i(
      public_strict
      auth_required
      guest_only
    ).freeze

    ACCESS_POLICY_RULES = Concurrent::Map.new

    # Cookie keys - environment-dependent naming
    # Production: "__Secure-" prefix for secure cookies
    # Dev/Test: no prefix (String, not Symbol)
    ACCESS_COOKIE_KEY = Rails.env.production? ? "__Secure-jit_auth_access" : "jit_auth_access"
    REFRESH_COOKIE_KEY = Rails.env.production? ? "__Secure-jit_auth_refresh" : "jit_auth_refresh"

    # Token TTLs
    ACCESS_TOKEN_TTL = ENV.fetch("AUTH_ACCESS_TOKEN_TTL", 1.hour.to_i).to_i.seconds
    REFRESH_TOKEN_TTL = 30.days
    RESTRICTED_SESSION_TTL = 15.minutes
    SESSION_LIMIT_HARD_REJECT_MESSAGE = "セッション数上限に達しています"

    AUDIT_EVENTS = {
      logged_in: "LOGGED_IN",
      logged_out: "LOGGED_OUT",
      login_failed: "LOGIN_FAILED",
      token_refreshed: "TOKEN_REFRESHED",
    }.freeze

    module JwtConfiguration
      def self.issuer
        ENV.fetch("AUTH_JWT_ISSUER", "umaxica-auth")
      end

      def self.audiences
        raw = ENV["AUTH_JWT_AUDIENCES"].to_s
        audiences = raw.split(",").map(&:strip)
        audiences.reject!(&:empty?)
        audiences.presence || ["umaxica-api"]
      end

      def self.private_key
        private_key_base64 = ENV["JWT_PRIVATE_KEY"] ||
          Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
        raise "Auth JWT private key not configured in credentials" if private_key_base64.blank?

        private_key_der = Base64.decode64(private_key_base64)
        OpenSSL::PKey::EC.new(private_key_der)
      end

      def self.public_key
        public_key_base64 = ENV["JWT_PUBLIC_KEY"] ||
          Rails.application.credentials.dig(:JWT, :PUBLIC_KEY)
        raise "Auth JWT public key not configured in credentials" if public_key_base64.blank?

        public_key_der = Base64.decode64(public_key_base64)
        OpenSSL::PKey::EC.new(public_key_der)
      end
    end

    class Token
      JWT_ALGORITHM = "ES384"

      class << self
        def encode(resource, host:, session_public_id: nil, resource_type: nil)
          return nil unless valid_encode_params?(resource, host)

          # Use provided resource_type or fallback to class name
          type = resource_type || resource.class.name.downcase
          payload = build_payload(resource, session_public_id, type)
          JWT.encode(payload, JwtConfiguration.private_key, JWT_ALGORITHM)
        rescue StandardError => error
          Rails.event.notify(
            "authentication.token.generation.failed",
            error_class: error.class.name,
            error_message: error.message,
            backtrace: error.backtrace.first(5),
            resource_type: resource.class.name,
            resource_id: resource.id,
          )
          nil
        end

        # rubocop:disable Metrics/MethodLength
        def decode(token, host:)
          return nil if token.blank? || host.blank?

          payload, = JWT.decode(token, JwtConfiguration.public_key, true, decode_options)
          payload
        rescue JWT::ExpiredSignature
          Rails.event.notify("authentication.token.verification.expired", host: host)
          nil
        rescue JWT::DecodeError, JWT::VerificationError => error
          Rails.event.notify(
            "authentication.token.verification.failed",
            error_class: error.class.name,
            host: host,
          )
          nil
        rescue StandardError => error
          Rails.event.notify(
            "authentication.token.verification.error",
            error_class: error.class.name,
            error_message: error.message,
            host: host,
          )
          nil
        end

        # rubocop:enable Metrics/MethodLength

        def extract_subject(payload)
          payload&.dig("sub")
        end

        def extract_type(payload)
          payload&.dig("type")
        end

        def extract_session_id(payload)
          payload&.dig("sid")
        end

        def extract_jti(payload)
          payload&.dig("jti")
        end

        private

        def valid_encode_params?(resource, host)
          return false if resource.nil? || host.blank?
          return false unless resource.respond_to?(:id)
          return false if resource.id.blank?

          true
        end

        def build_payload(resource, session_public_id, type)
          now = Time.current

          payload = {
            "iat" => now.to_i,
            "exp" => (now + Auth::Base::ACCESS_TOKEN_TTL).to_i,
            "jti" => Jit::Security::Jwt::JtiGenerator.generate,
            "iss" => JwtConfiguration.issuer,
            "aud" => JwtConfiguration.audiences,
            "sub" => resource.id,
            "type" => type,
          }
          payload["sid"] = session_public_id if session_public_id.present?
          payload
        end

        def decode_options
          {
            algorithms: [JWT_ALGORITHM],
            verify_iat: true,
            verify_exp: true,
            verify_iss: true,
            iss: JwtConfiguration.issuer,
            verify_aud: true,
            aud: JwtConfiguration.audiences,
          }
        end
      end
    end

    def logged_in?
      current_resource.present?
    end

    # ======================================================================
    # Pre-Authentication Guards
    # ======================================================================

    # Ensures user is not already logged in
    # Renders bad_request with message if user is logged in
    # Used for authentication endpoints (login)
    #
    # @param message_key [String] Optional translation key for the error message
    # @return [nil] Returns nil if user is logged in (stops filter chain)
    def ensure_not_logged_in(message_key: nil)
      return unless logged_in?

      message = message_key ? t(message_key) : "権限がありません"
      render plain: message, status: :unauthorized
      nil
    end

    # Ensures user is not already logged in (registration variant)
    # Redirects to root with alert message if user is logged in
    # Used for registration endpoints
    #
    # @param redirect_path [String] Path to redirect to (default: "/")
    # @param message_key [String] Optional translation key for the alert message
    def ensure_not_logged_in_for_registration(redirect_path: "/", message_key: nil)
      return unless logged_in?

      message = message_key ? t(message_key) : "権限がありません"

      if request.format.json?
        render plain: message, status: :unauthorized
      else
        redirect_to redirect_path, alert: message
      end
    end

    # Checks if user is logged in and renders error if so (inline variant)
    # Returns true if user is logged in, false otherwise
    # Useful for inline checks in actions
    #
    # @param message_key [String] Translation key for the error message
    # @return [Boolean] true if user is logged in, false otherwise
    def reject_if_logged_in(message_key)
      if logged_in?
        render plain: t(message_key), status: :bad_request
        true
      else
        false
      end
    end

    # Reject if user/staff is already logged in with 401 Unauthorized
    def reject_logged_in_session
      if logged_in?
        render plain: "権限がありません", status: :unauthorized
      end
    end

    # ======================================================================
    # Redirect Parameter Handling
    # ======================================================================

    # Default session key for storing redirect parameter
    DEFAULT_RD_SESSION_KEY = :user_email_authentication_rd

    # Preserves the redirect parameter in session and returns it for immediate use
    #
    # @param session_key [Symbol] The session key to store rd parameter in
    # @return [String, nil] The rd parameter value if present
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
    def add_rd_to_params!(redirect_params, session_key = DEFAULT_RD_SESSION_KEY)
      rd_value = peek_redirect_parameter(session_key)
      redirect_params[:rd] = rd_value if rd_value.present?
      redirect_params
    end

    # ======================================================================
    # Session Authentication
    # ======================================================================

    # Loads authentication session data and validates expiry
    # Returns the found record or handles redirect on expiry
    #
    # @param session_key [Symbol, String] The session key to load from
    # @param model_class [Class] The model class to load
    # @param redirect_path [String, Symbol] Where to redirect on session expiry
    # @param redirect_message [String] The translation key for expiry message
    # @param block [Proc] Optional block for additional validation
    # @return [ActiveRecord::Base, nil] The loaded record or nil
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
    def store_authentication_session(session_key, value)
      session[session_key] = value
    end

    # Clears authentication session data
    #
    # @param session_keys [Array<Symbol, String>] The session keys to clear
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
    def validate_session_expiry(session_data, expiry_key = "expires_at")
      return false if session_data.blank?
      return true unless session_data[expiry_key]

      session_data[expiry_key].to_i > Time.now.to_i
    end

    # Loads a record from session with additional validation
    #
    # @param session_key [Symbol, String] The session key containing the record ID
    # @param model_class [Class] The model class to load
    # @param validations [Hash] Additional validations to perform
    # @return [ActiveRecord::Base, nil] The loaded record or nil
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def current_account
      current_resource
    end

    def current_session_public_id
      @current_session_public_id
    end

    def current_resource
      return @current_resource if defined?(@current_resource)

      @current_resource = load_current_resource
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def log_in(resource, record_login_audit: true, token_kind_id: "BROWSER_WEB", require_totp_check: true)
      reset_session

      if require_totp_check
        totp_result = check_totp_requirement(resource)
        return totp_result if totp_result
      end

      session_limit_state = session_limit_state_for(resource)

      if session_limit_state == :hard_reject
        Rails.event.notify(
          "session.limit.hard_reject",
          "#{resource_type}_id": resource.id,
          ip_address: request_ip_address,
        )
        return {
          status: :session_limit_hard_reject,
          http_status: :conflict,
          message: SESSION_LIMIT_HARD_REJECT_MESSAGE,
        }
      end

      is_restricted = session_limit_state == :issue_restricted
      store_pending_login_resource(resource) if is_restricted

      kind_id = resolve_token_kind_id(token_kind_id)

      # Create token with appropriate status
      token_status = is_restricted ? token_class::STATUS_RESTRICTED : token_class::STATUS_ACTIVE
      token_record = create_login_token_record(resource, kind_id, status: token_status)

      # Generate SHA3-based refresh token
      restricted_expires_at = is_restricted ? restricted_session_expires_at : nil
      refresh_plain = token_record.rotate_refresh_token!(expires_at: restricted_expires_at)

      if is_restricted
        Rails.event.notify(
          "session.restricted.issued",
          "#{resource_type}_id": resource.id,
          user_token_id: token_record.public_id,
          expires_at: restricted_expires_at&.iso8601,
          ip_address: request_ip_address,
        )
      end

      # Generate JWT access token with explicit resource_type
      access_token = Token.encode(
        resource,
        host: request.host,
        session_public_id: token_record.public_id,
        resource_type: resource_type,
      )

      # Always set cookies (even for JSON responses - required for Edge/SPA)
      set_auth_cookies(access_token: access_token, refresh_token: refresh_plain)

      Sign::Risk::Emitter.emit(
        "session_issued",
        user_id: resource.id,
        user_token_id: token_record.public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { auth_method: token_kind_id, restricted: is_restricted },
      )

      record_audit(AUDIT_EVENTS[:logged_in], resource: resource) if record_login_audit

      result = {
        status: :success,
        access_token: access_token,
        refresh_token: refresh_plain,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_TTL.to_i,
      }

      # If session is restricted, issue session limit gate and indicate need for session management
      if is_restricted
        result[:restricted] = true
        result[:session_management_required] = true
        issue_session_limit_gate!(
          return_to: request.fullpath,
          flow: "#{controller_path}.session",
        )
      end

      result
    end

    def refresh_access_token(refresh_plain)
      clear_refresh_failure!

      refresh_public_id, = token_class.parse_refresh_token(refresh_plain.to_s)
      token_record = find_refresh_token_record(refresh_public_id)
      return handle_restricted_refresh_rejected(token_record, refresh_public_id) if token_record&.restricted?

      result = Sign::RefreshTokenService.call(refresh_token: refresh_plain)
      token_record = result[:token]
      new_refresh_plain = result[:refresh_token]

      return handle_missing_refresh_token(refresh_public_id) unless token_record.is_a?(token_class)

      # Load resource from token record
      # No special test handling - same code path for all environments
      resource = token_record.public_send(resource_type)

      return handle_inactive_resource(resource, refresh_public_id, token_record) unless resource&.active?

      build_refreshed_session(resource, token_record, new_refresh_plain)
    rescue Sign::InvalidRefreshToken => e
      handle_invalid_refresh_token(e, refresh_public_id)
    rescue StandardError => e
      Rails.logger.error "[Auth] Refresh Error: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(10).join("\n")
      handle_refresh_error(e, refresh_public_id, resource)
    end

    def refresh_failure_status
      @refresh_failure_status || :unauthorized
    end

    def refresh_failure_code
      @refresh_failure_code || "invalid_refresh_token"
    end

    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def log_out
      resource = current_resource

      destroy_refresh_token_from_cookie

      cookies.delete ACCESS_COOKIE_KEY, cookie_deletion_options
      cookies.delete REFRESH_COOKIE_KEY, cookie_deletion_options

      record_audit(AUDIT_EVENTS[:logged_out], resource: resource) if resource
      reset_session
      @current_resource = nil
    end

    def transparent_refresh_access_token
      return if logged_in?

      # Loop guard: prevents infinite refresh loops within the same request
      return if request.env["jit_auth_refreshed"]

      refresh_plain = cookies[REFRESH_COOKIE_KEY]
      return if refresh_plain.blank?

      # Mark as refreshed to prevent recursion
      request.env["jit_auth_refreshed"] = true

      refreshed = refresh_access_token(refresh_plain)
      unless refreshed
        Rails.logger.debug { "[Auth] transparent_refresh: FAILURE" }
        cookies.delete ACCESS_COOKIE_KEY, cookie_deletion_options
        cookies.delete REFRESH_COOKIE_KEY, cookie_deletion_options
        return
      end

      Rails.logger.debug { "[Auth] transparent_refresh: SUCCESS. User: #{refreshed[:user].present?}" }
      @current_resource = refreshed[:user]
    end

    def authenticate!
      if logged_in?
        Sign::Risk::Enforcer.call(current_resource)
        return
      end

      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        Sign::Risk::Emitter.emit(
          "auth_required",
          ip: request&.remote_ip,
          user_agent: request&.user_agent,
          request_id: request&.request_id,
          path: request&.fullpath,
          method: request&.request_method,
        )
        rt = Base64.urlsafe_encode64(request.original_url)
        redirect_to(
          sign_in_url_with_return(rt),
          allow_other_host: true,
          alert: I18n.t("errors.messages.login_required"),
        )
      end
    end

    # Abstract methods - must be implemented by including modules
    def resource_class
      raise NotImplementedError, "resource_class must be implemented"
    end

    def token_class
      raise NotImplementedError, "token_class must be implemented"
    end

    def audit_class
      raise NotImplementedError, "audit_class must be implemented"
    end

    def resource_type
      raise NotImplementedError, "resource_type must be implemented"
    end

    def resource_foreign_key
      raise NotImplementedError, "resource_foreign_key must be implemented"
    end

    def test_header_key
      raise NotImplementedError, "test_header_key must be implemented"
    end

    def sign_in_url_with_return(return_to)
      raise NotImplementedError, "sign_in_url_with_return must be implemented"
    end

    # Authorization abstract methods - RBAC / ABAC placeholders
    def am_i_user?
      raise NotImplementedError, "am_i_user? must be implemented"
    end

    def am_i_staff?
      raise NotImplementedError, "am_i_staff? must be implemented"
    end

    def am_i_owner?
      raise NotImplementedError, "am_i_owner? must be implemented"
    end

    included do
      include ::SessionLimitGate

      # Important: prepend first so this runs before other before_action hooks.
      prepend_before_action :enforce_access_policy! if respond_to?(:prepend_before_action)
      if respond_to?(:helper_method)
        helper_method :current_account, :current_session_public_id, :current_session_restricted?
      end
    end

    class_methods do
      # Declare policy for controller or specific actions (only/except).
      def access_policy_rules
        ACCESS_POLICY_RULES.fetch_or_store(self) do
          parent_rules =
            if superclass.respond_to?(:access_policy_rules)
              superclass.access_policy_rules
            else
              []
            end
          parent_rules.dup
        end
      end

      def access_policy(policy, only: nil, except: nil, **options)
        policy = policy.to_sym
        raise InvalidPolicyError, "Invalid policy: #{policy.inspect}" unless VALID_POLICIES.include?(policy)

        rule = {
          policy: policy,
          only: Array(only).map(&:to_s).presence,
          except: Array(except).map(&:to_s).presence,
          options: options,
        }

        ACCESS_POLICY_RULES[self] = access_policy_rules + [rule]
      end

      # Readable shortcuts.
      def public_strict!(**) = access_policy(:public_strict, **)

      def auth_required!(**) = access_policy(:auth_required, **)

      def guest_only!(**) = access_policy(:guest_only, **)

      # --- Skip guardrails ---
      # Disallow removing enforce_access_policy! via skip_before_action.
      def skip_before_action(*filters, **options)
        # Note: In Ruby 4.0+/Rails 8+, some callers pass Hash as positional argument
        # instead of keyword arguments. Filter out non-symbol entries.
        flattened = filters.flatten
        action_names =
          flattened.filter_map do |filter|
            next unless filter.respond_to?(:to_sym) && !filter.is_a?(Hash)

            filter.to_sym
          end
        if action_names.include?(:enforce_access_policy!)
          raise SkipNotAllowedError, "skip_before_action :enforce_access_policy! is prohibited (#{name})"
        end

        super
      end

      # Some code uses skip_action_callback, so lock this down too.
      def skip_action_callback(*args, **kwargs)
        # skip_action_callback(:process_action, :before, :enforce_access_policy!)
        if args.map(&:to_sym).include?(:enforce_access_policy!)
          raise SkipNotAllowedError, "skip_action_callback :enforce_access_policy! is prohibited (#{name})"
        end

        super
      end
    end

    private

    # ======================================================================
    # Withdrawal Gate - Confines deactivated users to configuration edit
    # ======================================================================

    def enforce_withdrawal_gate!
      return unless logged_in?
      return unless current_resource
      return unless current_resource.respond_to?(:deactivated?)
      return unless current_resource.deactivated?

      # Allowlist: configuration edit and withdrawal flow
      return if withdrawal_gate_allowlisted?

      # API/JSON: return 403 Forbidden
      if request.format.json? || !request.format.html?
        render json: { error: "WITHDRAWAL_REQUIRED" }, status: :forbidden
        return
      end

      # HTML: redirect to configuration edit page
      safe_redirect_to(withdrawal_gate_redirect_path, fallback: "/configuration/edit", status: :found)
    end

    def withdrawal_gate_allowlisted?
      # Allowlist: configuration edit
      return true if controller_path.end_with?("/configurations") && action_name == "edit"

      # Allowlist: withdrawal controller actions
      return true if controller_path.end_with?("configuration/withdrawals") && %w(new edit update
                                                                                  create).include?(action_name)

      # Allowlist: health/assets (rarely needed but safe)
      return true if controller_path == "rails/health"

      false
    end

    def withdrawal_gate_redirect_path
      if respond_to?(:edit_sign_app_configuration_path, true)
        edit_sign_app_configuration_path(ri: params[:ri])
      elsif respond_to?(:edit_sign_org_configuration_path, true)
        edit_sign_org_configuration_path(ri: params[:ri])
      else
        "/configuration/edit"
      end
    rescue StandardError => e
      Rails.logger.error("Failed to resolve configuration edit path: #{e.message}")
      "/configuration/edit"
    end

    def cookie_options
      opts = {
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        path: "/",
      }
      opts[:domain] = shared_cookie_domain if shared_cookie_domain
      opts
    end

    def cookie_deletion_options
      opts = { path: "/" }
      opts[:domain] = shared_cookie_domain if shared_cookie_domain
      opts
    end

    def set_auth_cookies(access_token:, refresh_token:)
      # Access cookie
      cookies[ACCESS_COOKIE_KEY] = cookie_options.merge(
        value: access_token,
        expires: ACCESS_TOKEN_TTL.from_now,
      )
      # Refresh cookie - use regular cookies (not encrypted)
      cookies[REFRESH_COOKIE_KEY] = cookie_options.merge(
        value: refresh_token,
        expires: REFRESH_TOKEN_TTL.from_now,
      )
    end

    def shared_cookie_domain
      @shared_cookie_domain ||= resolve_cookie_domain
    end

    def derive_cookie_domain_from_host
      return nil unless request&.host

      host_parts = request.host.split(".")
      return nil if host_parts.length < 2

      host_parts.last(2).join(".")
    end

    def formatted_domain(value)
      return nil if value.blank?

      value.start_with?(".") ? value : ".#{value}"
    end

    def extract_access_token(cookie_key)
      return nil unless respond_to?(:request, true) && request

      auth_header = request.headers["Authorization"]
      if auth_header.present?
        prefix, token = auth_header.split(" ", 2)
        return token if prefix.casecmp("Bearer").zero? && token.present?
      end

      cookies[cookie_key]
    end

    def record_audit(event_id, resource:, actor: resource)
      return unless resource && event_id

      Rails.logger.debug { "[Auth] record_audit: Event #{event_id}, Resource #{resource&.id}" }

      # Delegate to AuditWriter with best-effort semantics
      # This ensures audit failures do not block authentication
      Auth::AuditWriter.write(
        audit_class,
        event_id,
        resource: resource,
        actor: actor,
        ip_address: request_ip_address,
      )
    end

    def handle_missing_refresh_token(refresh_public_id)
      set_refresh_failure!(:unauthorized, "invalid_refresh_token")

      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_public_id,
        reason: "token_not_found",
        ip_address: request_ip_address,
      )

      Sign::Risk::Emitter.emit(
        "refresh_failed",
        user_token_id: refresh_public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { reason: "token_not_found" },
      )

      nil
    end

    def handle_inactive_resource(resource, refresh_public_id, token_record)
      if resource.respond_to?(:deactivated?) && resource.deactivated?
        set_refresh_failure!(:forbidden, "withdrawal_required")
      else
        set_refresh_failure!(:unauthorized, "invalid_refresh_token")
      end

      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        "#{resource_type}_id": resource&.id,
        refresh_token_id: refresh_public_id,
        reason: "#{resource_type}_inactive",
        ip_address: request_ip_address,
      )

      Sign::Risk::Emitter.emit(
        "refresh_failed",
        user_id: resource&.id,
        user_token_id: refresh_public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { reason: "#{resource_type}_inactive" },
      )

      # S3: Do not destroy token - only revoke it
      # This prevents destructive behavior in transparent refresh
      TokenRecord.connected_to(role: :writing) do
        token_record.update!(revoked_at: Time.current) if token_record.revoked_at.nil?
      end
      nil
    end

    def build_refreshed_session(resource, token_record, new_refresh_plain)
      new_access_token = Token.encode(
        resource,
        host: request.host,
        session_public_id: token_record.public_id,
        resource_type: resource_type,
      )

      set_auth_cookies(access_token: new_access_token, refresh_token: new_refresh_plain)

      Sign::Risk::Emitter.emit(
        "refresh_rotated",
        user_id: resource.id,
        user_token_id: token_record.public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
      )

      Rails.event.notify(
        "#{resource_type}.token.refreshed",
        "#{resource_type}_id": resource.id,
        old_refresh_token_id: token_record.public_id,
        new_refresh_token_id: token_record.public_id,
        ip_address: request_ip_address,
      )

      # S1: Audit with best-effort semantics - failure does not block refresh
      # AuditWriter.write handles exceptions internally and notifies observers
      record_audit(AUDIT_EVENTS[:token_refreshed], resource: resource)

      Sign::Risk::Enforcer.call(resource)

      {
        access_token: new_access_token,
        refresh_token: new_refresh_plain,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_TTL.to_i,
        user: resource,
      }
    end

    def request_ip_address
      (respond_to?(:request, true) && request) ? request.remote_ip : nil
    end

    def handle_invalid_refresh_token(exception, refresh_public_id)
      set_refresh_failure!(:unauthorized, "invalid_refresh_token")

      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_public_id,
        reason: exception.class.name,
        ip_address: request_ip_address,
      )

      Sign::Risk::Emitter.emit(
        "refresh_failed",
        user_token_id: refresh_public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { reason: exception.class.name },
      )

      nil
    end

    def handle_refresh_error(exception, refresh_public_id, resource)
      set_refresh_failure!(:unauthorized, "invalid_refresh_token")

      Rails.event.notify(
        "#{resource_type}.token.refresh.error",
        "#{resource_type}_id": resource&.id,
        refresh_token_id: refresh_public_id,
        error_message: exception.message,
        ip_address: request_ip_address,
      )

      Sign::Risk::Emitter.emit(
        "refresh_failed",
        user_id: resource&.id,
        user_token_id: refresh_public_id,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { error_class: exception.class.name },
      )

      nil
    end

    def handle_restricted_refresh_rejected(token_record, refresh_public_id)
      expired = token_record.refresh_expires_at.present? && token_record.refresh_expires_at <= Time.current

      if expired && token_record.revoked_at.nil?
        TokenRecord.connected_to(role: :writing) do
          token_record.revoke!
        end
        Rails.event.notify(
          "session.restricted.expired",
          user_token_id: token_record.public_id,
          "#{resource_type}_id": token_record.public_send("#{resource_type}_id"),
        )
      end

      set_refresh_failure!(:forbidden, "restricted_session")

      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_public_id,
        reason: expired ? "restricted_expired" : "restricted_session",
        ip_address: request_ip_address,
      )

      nil
    end

    def find_refresh_token_record(refresh_public_id)
      return nil if refresh_public_id.blank?

      find_logic = -> { token_class.find_by(public_id: refresh_public_id, rotated_at: nil) }
      TokenRecord.connected_to(role: :reading, &find_logic)
    end

    def set_refresh_failure!(status, code)
      @refresh_failure_status = status
      @refresh_failure_code = code
    end

    def clear_refresh_failure!
      @refresh_failure_status = nil
      @refresh_failure_code = nil
    end

    def load_current_resource
      if Rails.env.test?
        resource = load_from_test_header
        return resource if resource
      end

      resource = load_from_token
      return nil if resource_withdrawn?(resource)

      resource
    end

    def load_from_test_header
      return nil unless respond_to?(:request, true) && request

      test_id = request.headers[test_header_key]
      return nil unless test_id

      resource = resource_class.find_by(id: test_id)
      if resource
        @bypass_withdrawn_check = true
        test_session_id = request.headers["X-TEST-SESSION-PUBLIC-ID"]
        @current_session_public_id = test_session_id if test_session_id.present?
      end
      resource
    end

    def load_from_token
      access_token = extract_access_token(ACCESS_COOKIE_KEY)
      return nil if access_token.blank?

      payload = Token.decode(access_token, host: request.host)
      return nil if payload.blank?
      return nil unless Token.extract_type(payload) == resource_type

      sid = Token.extract_session_id(payload)
      return nil if sid.blank?

      # Use replica for reading, but skip connected_to in tests to ensure transaction visibility
      check_logic =
        -> {
          scope = token_class.where(public_id: sid)
          scope = scope.where(revoked_at: nil) if token_class.column_names.include?("revoked_at")
          scope.exists?
        }

      token_exists =
        if Rails.env.test?
          # Ensure visibility by using writing connection which holds the test transaction
          TokenRecord.connected_to(role: :writing, &check_logic)
        else
          TokenRecord.connected_to(role: :reading, &check_logic)
        end
      return nil unless token_exists

      @current_session_public_id = sid

      resource_class.find_by(id: Token.extract_subject(payload))
    end

    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def resource_withdrawn?(resource)
      return false unless resource&.respond_to?(:withdrawn?)
      return false if @bypass_withdrawn_check

      resource.withdrawn?
    end

    def destroy_refresh_token_from_cookie
      # Use regular cookies (not encrypted)
      token_value = cookies[REFRESH_COOKIE_KEY]
      return unless token_value

      public_id, = token_class.parse_refresh_token(token_value)
      return unless public_id

      destroy_logic =
        -> {
          token_class.find_by(public_id: public_id)&.destroy
        }

      if Rails.env.test?
        destroy_logic.call
      else
        TokenRecord.connected_to(role: :writing, &destroy_logic)
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.event.notify(
        "#{resource_type}.token.destroy.failed",
        token_id: public_id,
        error_message: e.message,
        ip_address: request_ip_address,
      )
    end

    def resolve_cookie_domain
      configured = ENV["SIGN_COOKIE_DOMAIN"]&.strip
      return formatted_domain(configured) if configured.present?

      derived = derive_cookie_domain_from_host
      formatted_domain(derived)
    end

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

    # --- Policy enforcement methods ---

    def enforce_access_policy!
      rule = resolve_policy_rule

      policy = rule[:policy]
      options = rule[:options] || {}

      Rails.logger.warn(
        "AUTH_POLICY: Resolved #{policy} for #{self.class.name}##{action_name} " \
        "(Rules: #{self.class.access_policy_rules.size})",
      )

      case policy
      when :public_strict
        enforce_public_strict!(options)
      when :auth_required
        enforce_auth_required!(options)
      when :guest_only
        enforce_guest_only!(options)
      else
        raise InvalidPolicyError, "Unexpected policy: #{policy.inspect}"
      end
    end

    def resolve_policy_rule
      rule = resolve_access_policy_for(action_name)

      if rule.nil?
        Rails.logger.warn "AUTH_POLICY: Missing for #{self.class.name}##{action_name}"
        raise MissingPolicyError,
              "Missing access_policy for #{self.class.name}##{action_name}. " \
              "Declare one of: #{VALID_POLICIES.join(", ")}"
      end
      rule
    end

    def resolve_access_policy_for(action)
      action = action.to_s

      # Last rule wins so controller-wide policies can be overridden per action.
      rules = self.class.access_policy_rules
      return nil if rules.blank?

      rules.reverse_each do |rule|
        next if rule[:only].present? && rule[:only].exclude?(action)
        next if rule[:except].present? && rule[:except].include?(action)

        return rule
      end

      nil
    end

    # --- Behavior implementation (align with your auth stack) ---

    def enforce_public_strict!(_options = {})
      # If you avoid touching current_user/current_resource here,
      # the safest default is to do nothing.
      true
    end

    def enforce_auth_required!(options = {})
      # Example: use Auth::Base logged_in? / current_resource.
      return true if respond_to?(:logged_in?) && logged_in?

      # Branch HTML vs API (or delegate to your responder).
      if request.format.json? || options[:request_format] == :json
        handle_auth_required_json(options)
      else
        handle_auth_required_html(options)
      end
    end

    def enforce_guest_only!(options = {})
      # Guest-only policy: block logged-in users.
      return true unless respond_to?(:logged_in?) && logged_in?

      # Exception: deactivated users should be handled by withdrawal gate, not guest_only
      if current_resource.respond_to?(:deactivated?) && current_resource.deactivated?
        return true
      end

      if request.format.json? || options[:request_format] == :json
        handle_guest_only_json(options)
      else
        handle_guest_only_with_status_checks(options)
      end
    end

    def create_login_token_record(resource, token_kind_id, status: nil)
      TokenRecord.connected_to(role: :writing) do
        token_attributes = { resource_foreign_key => resource.id }
        # Determine kind column based on resource type (user_token_kind_id or staff_token_kind_id)
        kind_column = "#{resource_type}_token_kind_id"
        if token_class.column_names.include?(kind_column)
          ensure_token_kind_exists!(token_kind_id)
          token_attributes[kind_column] = token_kind_id
        end

        # Set status if provided (for restricted sessions)
        token_attributes[:status] = status if status.present?

        token_class.create!(token_attributes)
      end
    end

    def resolve_token_kind_id(raw_kind_id)
      return raw_kind_id unless raw_kind_id.is_a?(String)

      kind_column = "#{resource_type}_token_kind_id"
      return raw_kind_id unless token_class.columns_hash[kind_column]&.type == :integer

      kind_model = token_kind_model
      if kind_model.column_names.include?("code")
        begin
          return kind_model.find_by!(code: raw_kind_id).id
        rescue ActiveRecord::RecordNotFound
          Rails.logger.error(
            "AUTH_TOKEN_KIND_MISSING: #{kind_model.name} code=#{raw_kind_id} resource_type=#{resource_type}",
          )
          raise ActiveRecord::RecordNotFound,
                "Missing #{kind_model.name} code=#{raw_kind_id} for #{resource_type} login"
        end
      end

      resolved =
        case [resource_type, raw_kind_id]
        when ["staff", "BROWSER_WEB"] then StaffTokenKind::BROWSER_WEB
        when ["staff", "CLIENT_IOS"] then StaffTokenKind::CLIENT_IOS
        when ["staff", "CLIENT_ANDROID"] then StaffTokenKind::CLIENT_ANDROID
        when ["user", "BROWSER_WEB"] then UserTokenKind::BROWSER_WEB
        when ["user", "CLIENT_IOS"] then UserTokenKind::CLIENT_IOS
        when ["user", "CLIENT_ANDROID"] then UserTokenKind::CLIENT_ANDROID
        end

      return resolved if resolved

      raise ActiveRecord::RecordNotFound, "Missing #{kind_model.name} for code=#{raw_kind_id}"
    end

    def ensure_token_kind_exists!(token_kind_id)
      return if token_kind_id.blank?

      kind_model = token_kind_model
      kind_model.find(token_kind_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error(
        "AUTH_TOKEN_KIND_MISSING: #{kind_model.name} id=#{token_kind_id} resource_type=#{resource_type}",
      )
      raise ActiveRecord::RecordNotFound,
            "Missing #{kind_model.name} id=#{token_kind_id} for #{resource_type} login"
    end

    def token_kind_model
      case resource_type
      when "user" then UserTokenKind
      when "staff" then StaffTokenKind
      else
        raise ActiveRecord::RecordNotFound, "Missing token kind model for resource_type=#{resource_type}"
      end
    end

    def check_totp_requirement(resource)
      return unless mfa_required_for?(resource)

      set_pending_mfa!(resource: resource, primary: "mfa")
      { status: :mfa_required }
    end

    def set_pending_mfa!(resource:, primary:, return_to: nil, ri: nil, auth_method: nil)
      issued_at = Time.current.to_i
      expires_at = pending_mfa_ttl.from_now.to_i
      session[:pending_mfa] = {
        "public_id" => SecureRandom.hex(16),
        "user_id" => resource.id,
        "resource_type" => resource_type,
        "primary" => primary.to_s,
        "auth_method" => auth_method.to_s.presence || primary.to_s,
        "return_to" => return_to.presence,
        "ri" => ri.to_s.presence,
        "issued_at" => issued_at,
        "expires_at" => expires_at,
        "attempts" => 0,
      }
      # Backward compatibility for existing controllers still using mfa_user_id.
      session[:mfa_user_id] = resource.id
    end

    def pending_mfa
      raw = session[:pending_mfa]
      return nil unless raw.is_a?(Hash)

      raw.with_indifferent_access
    end

    def pending_mfa_ttl
      10.minutes
    end

    def pending_mfa_valid?
      data = pending_mfa
      return false unless data

      expires_at = data[:expires_at].to_i
      if expires_at.positive?
        return false if Time.current.to_i >= expires_at
      else
        issued_at = data[:issued_at].to_i
        return false if issued_at <= 0
        return false if Time.zone.at(issued_at) < pending_mfa_ttl.ago
      end

      true
    end

    def pending_mfa_user
      return nil unless pending_mfa_valid?

      user_id = pending_mfa[:user_id]
      return nil if user_id.blank?

      klass = respond_to?(:resource_class, true) ? resource_class : ::User
      klass.find_by(id: user_id)
    end

    def clear_pending_mfa!
      session.delete(:pending_mfa)
      session.delete(:mfa_user_id)
    end

    # Completes login after successful MFA verification.
    # Consumes the pending MFA session, logs in the user, and returns a result hash
    # with redirect information.
    #
    # @param user [User] the user to log in
    # @return [Hash] result with :status, :redirect_path, etc.
    def finalize_mfa_login!(user)
      return_to = pending_mfa&.dig(:return_to)
      clear_pending_mfa!

      result = log_in(user, require_totp_check: false)

      if result[:status] == :session_limit_hard_reject
        { status: :session_limit_hard_reject, message: result[:message], http_status: result[:http_status] }
      elsif result[:restricted]
        { status: :restricted, redirect_path: session_management_path }
      else
        { status: :success, redirect_path: return_to.presence }
      end
    end

    def session_management_path
      if respond_to?(:sign_app_in_session_path, true)
        sign_app_in_session_path
      elsif respond_to?(:sign_org_in_session_path, true)
        sign_org_in_session_path
      else
        "/in/session"
      end
    rescue StandardError
      "/in/session"
    end

    def default_after_login_path
      if respond_to?(:sign_app_root_path, true)
        sign_app_root_path
      elsif respond_to?(:sign_org_root_path, true)
        sign_org_root_path
      else
        "/"
      end
    rescue StandardError
      "/"
    end

    def complete_sign_in_or_start_mfa!(resource, rt:, ri:, auth_method:, token_kind_id: "BROWSER_WEB",
                                       record_login_audit: true)
      auth_method = auth_method.to_s
      return log_in(
        resource, record_login_audit: record_login_audit, token_kind_id: token_kind_id,
                  require_totp_check: false,
      ) if mfa_bypassed_for_auth_method?(auth_method) || !mfa_required_for?(resource)

      return_to = resolve_mfa_return_to(rt)
      set_pending_mfa!(resource: resource, primary: auth_method, return_to: return_to, ri: ri, auth_method: auth_method)

      {
        status: :mfa_required,
        redirect_path: mfa_entry_path(ri: ri),
        return_to: return_to,
      }
    end

    # Determine concurrent-session handling state for the resource.
    def session_limit_state_for(resource)
      max_sessions = max_sessions_for_resource(resource)
      active_count = count_active_sessions(resource)

      return :within_limit if active_count < max_sessions
      return :hard_reject if restricted_session_exists?(resource)

      :issue_restricted
    end

    # Returns the maximum allowed concurrent sessions for a resource
    def max_sessions_for_resource(resource)
      if resource.is_a?(::User)
        ::UserToken::MAX_SESSIONS_PER_USER
      elsif resource.is_a?(::Staff)
        ::StaffToken::MAX_SESSIONS_PER_STAFF
      else
        2 # Default fallback
      end
    end

    # Count active (non-revoked, non-restricted) sessions for a resource
    def count_active_sessions(resource)
      if resource.is_a?(::User)
        ::UserToken.active_status.where(user_id: resource.id).count
      elsif resource.is_a?(::Staff)
        ::StaffToken.active_status.where(staff_id: resource.id).count
      else
        0
      end
    end

    def restricted_session_exists?(resource)
      scope = find_restricted_sessions_scope(resource)
      scope.present? && scope.exists?
    end

    def find_restricted_sessions_scope(resource)
      if resource.is_a?(::User)
        ::UserToken.restricted_status.where(user_id: resource.id)
      elsif resource.is_a?(::Staff)
        ::StaffToken.restricted_status.where(staff_id: resource.id)
      end
    end

    def restricted_session_expires_at
      ttl = token_class.const_defined?(:RESTRICTED_TTL) ? token_class::RESTRICTED_TTL : RESTRICTED_SESSION_TTL
      Time.current + ttl
    end

    # Store the pending login resource ID for session management
    def store_pending_login_resource(resource)
      if resource.is_a?(::User)
        session[:pending_login_user_id] = resource.id
      elsif resource.is_a?(::Staff)
        session[:pending_login_staff_id] = resource.id
      end
    end

    # Get the current session token record
    def current_session
      return @current_session if defined?(@current_session)
      return nil unless current_session_public_id

      find_logic = -> { token_class.find_by(public_id: current_session_public_id, revoked_at: nil) }

      @current_session =
        if Rails.env.test?
          # Ensure visibility by using writing connection which holds the test transaction
          TokenRecord.connected_to(role: :writing, &find_logic)
        else
          TokenRecord.connected_to(role: :reading, &find_logic)
        end
    end

    # Check if the current session is restricted
    def current_session_restricted?
      current_session&.restricted?
    end

    def mfa_required_for?(resource)
      return false unless resource.is_a?(::User)
      return false unless resource.respond_to?(:multi_factor_enabled?)

      resource.multi_factor_enabled?
    end

    def mfa_bypassed_for_auth_method?(auth_method)
      %w(passkey social google apple).include?(auth_method.to_s)
    end

    def resolve_mfa_return_to(raw_value)
      return nil if raw_value.blank?

      decoded = decode_base64_urlsafe(raw_value)
      candidate = decoded.presence || raw_value

      safe_internal_path(candidate) || safe_external_url(candidate)
    end

    def decode_base64_urlsafe(value)
      Base64.urlsafe_decode64(value.to_s)
    rescue ArgumentError
      nil
    end

    def mfa_entry_path(ri: nil)
      if respond_to?(:sign_app_in_challenge_path, true)
        sign_app_in_challenge_path(ri: ri)
      elsif respond_to?(:sign_org_in_challenge_path, true)
        sign_org_in_challenge_path(ri: ri)
      else
        "/in/challenge"
      end
    rescue StandardError
      "/in/challenge"
    end

    def handle_auth_required_json(options)
      status = options[:status] || :unauthorized
      render json: { error: (options[:message] || "unauthorized") }, status: status
    end

    def handle_auth_required_html(options)
      path =
        if respond_to?(:sign_in_url_with_return, true)
          rt = Base64.urlsafe_encode64(request.original_url)
          sign_in_url_with_return(rt)
        elsif main_app.respond_to?(:sign_in_path)
          main_app.sign_in_path
        else
          "/sign/in"
        end
      message = options[:message] || I18n.t("errors.messages.login_required")
      redirect_to(path, allow_other_host: true, alert: message)
    end

    def handle_guest_only_json(options)
      status = options[:status] || :forbidden
      render json: { error: (options[:message] || "already_authenticated") }, status: status
    end

    def handle_guest_only_with_status_checks(options)
      if options[:status] == :unauthorized
        return render plain: (options[:message] || "権限がありません"), status: :unauthorized
      end
      if options[:status] == :bad_request
        return render plain: (options[:message] || "リクエストが不正です"), status: :bad_request
      end

      handle_guest_only_html(options)
    end

    def handle_guest_only_html(options)
      path =
        if respond_to?(:after_login_path, true)
          after_login_path
        elsif main_app.respond_to?(:after_login_path)
          main_app.after_login_path
        else
          "/"
        end
      message = options[:message] || I18n.t("errors.messages.already_authenticated")
      redirect_to(path, allow_other_host: true, alert: message)
    end
  end
end
