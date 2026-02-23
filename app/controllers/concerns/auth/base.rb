# typed: false
# frozen_string_literal: true

require "jwt"

module Auth
  module Base
    extend ActiveSupport::Concern
    include Common::Redirect

    # ==========================================================================
    # TOC (approximate)
    # 1) JWT & Token primitives ....................................... L40-L210
    # 2) Request guards (public API, I/O boundary) .................... L215-L275
    # 3) Redirect/checkpoint session flows (I/O boundary) ............. L277-L462
    # 4) Session auth lifecycle (public API, I/O boundary) ............ L464-L775
    # 5) Abstract contract & policy DSL ............................... L778-L907
    # 6) Private request/cookie/token I/O ............................. L909-L1505
    # 7) Policy/domain decisions ...................................... L1514-L1869
    # 8) MFA/session helper decisions ................................. L1873-L1966
    # ==========================================================================

    # ==========================================================================
    # 1) JWT & Token primitives
    # ==========================================================================

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
    ACCESS_COOKIE_KEY = Auth::CookieName.access
    REFRESH_COOKIE_KEY = Auth::CookieName.refresh
    DEVICE_COOKIE_KEY = Auth::CookieName.device(refresh_cookie_key: REFRESH_COOKIE_KEY)

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

    VALID_ACTOR_TYPES = %w(user staff).freeze

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
          Auth::TokenService.encode(
            resource, host: host, session_public_id: session_public_id,
                      resource_type: resource_type,
          )
        end

        def decode(token, host:)
          Auth::TokenService.decode(token, host: host)
        end

        def extract_subject(payload)
          Auth::TokenService.extract_subject(payload)
        end

        def extract_act(payload)
          Auth::TokenService.extract_act(payload)
        end

        def extract_type(payload)
          Auth::TokenService.extract_type(payload)
        end

        def validate_actor_claim!(payload, expected_act)
          Auth::TokenService.validate_actor_claim!(payload, expected_act)
        end

        def extract_session_id(payload)
          Auth::TokenService.extract_session_id(payload)
        end

        def extract_jti(payload)
          Auth::TokenService.extract_jti(payload)
        end
      end
    end

    def logged_in?
      current_resource.present?
    end

    # ======================================================================
    # 2) Request guards (public API, Request I/O boundary)
    # - Reads request format and writes HTTP response
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
    # 3) Redirect/checkpoint session flows (Session/params I/O boundary)
    # - Reads/writes params, flash, session
    # ======================================================================

    # Default session key for storing redirect parameter
    DEFAULT_RD_SESSION_KEY = Auth::IoKeys::Session::DEFAULT_RD
    CHECKPOINT_SESSION_KEY = Auth::IoKeys::Session::CHECKPOINT
    CHECKPOINT_TIMEOUT = 2.hours

    # Preserves the redirect parameter in session and returns it for immediate use
    #
    # @param session_key [Symbol] The session key to store rd parameter in
    # @return [String, nil] The rd parameter value if present
    def preserve_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      if params[Auth::IoKeys::Params::RD].present?
        session[session_key] = params[Auth::IoKeys::Params::RD]
        params[Auth::IoKeys::Params::RD]
      end
    end

    # Retrieves and clears the redirect parameter from session
    # Falls back to params[:rd] if session is empty
    #
    # @param session_key [Symbol] The session key to retrieve from
    # @return [String, nil] The rd parameter value
    def retrieve_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      rd_param = params[Auth::IoKeys::Params::RD].presence || session[session_key]
      session[session_key] = nil
      rd_param
    end

    # Retrieves redirect parameter without clearing session
    #
    # @param session_key [Symbol] The session key to retrieve from
    # @return [String, nil] The rd parameter value
    def peek_redirect_parameter(session_key = DEFAULT_RD_SESSION_KEY)
      params[Auth::IoKeys::Params::RD].presence || session[session_key]
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
      redirect_params[Auth::IoKeys::Params::RD] = rd_value if rd_value.present?
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
      redirect_params[Auth::IoKeys::Params::RD] = rd_value if rd_value.present?
      redirect_params
    end

    # ======================================================================
    # 3-1) Checkpoint flow (Session/header I/O boundary + test hook)
    # ======================================================================

    def issue_checkpoint!(kind: "mock", state: "new", payload: {})
      session[CHECKPOINT_SESSION_KEY] = {
        "issued_at" => Time.current.to_i,
        "kind" => kind.to_s,
        "state" => state.to_s,
      }.merge(payload.stringify_keys)
    end

    # Injects checkpoint state from a test header (X-TEST-CHECKPOINT).
    # Used as a before_action in checkpoint controllers to seed session
    # state for integration tests that cannot set session directly.
    def maybe_inject_test_checkpoint!
      return unless Rails.env.test?

      raw = request.headers[Auth::IoKeys::Headers::TEST_CHECKPOINT]
      return if raw.blank?
      return if session[CHECKPOINT_SESSION_KEY].present?

      session[CHECKPOINT_SESSION_KEY] = JSON.parse(raw)
    end

    def checkpoint_state
      raw = session[CHECKPOINT_SESSION_KEY]
      return nil unless raw.is_a?(Hash)

      raw.with_indifferent_access
    end

    def checkpoint_active?
      checkpoint_state.present? && !checkpoint_expired?
    end

    def checkpoint_expired?
      data = checkpoint_state
      return true if data.blank?

      issued_at = data[:issued_at].to_i
      return true if issued_at <= 0

      Time.current.to_i >= issued_at + CHECKPOINT_TIMEOUT.to_i
    end

    def refresh_checkpoint_dimension!(state: "updated")
      data = checkpoint_state
      return unless data

      session[CHECKPOINT_SESSION_KEY] = data.merge(
        "issued_at" => Time.current.to_i,
        "state" => state.to_s,
      )
    end

    def consume_checkpoint!
      session.delete(CHECKPOINT_SESSION_KEY)
    end

    def safe_redirect_to_rd_or_default!(rd_param, default_path:)
      if rd_param.present?
        jump_to_generated_url(rd_param, fallback: default_path)
      else
        redirect_to default_path
      end
    end

    # ======================================================================
    # 4) Session auth lifecycle (public API, Cookie/session/request I/O boundary)
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

      # Clear any existing auth cookies to prevent conflicts with old sessions
      # This ensures we don't have duplicate cookies with different domains/paths
      # Note: We clear cookies before setting new ones, but preserve @current_resource
      # which will be set to the logged-in user after successful authentication
      cookies.delete ACCESS_COOKIE_KEY, cookie_deletion_options
      cookies.delete REFRESH_COOKIE_KEY, cookie_deletion_options
      clear_device_id_cookie!

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
      set_auth_cookies(access_token: access_token, refresh_token: refresh_plain, device_id: token_record.device_id)

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
      return handle_refresh_device_denied(token_record, refresh_public_id) unless refresh_device_allowed?(token_record)

      result = Sign::RefreshTokenService.call(refresh_token: refresh_plain)
      previous_token_record = result[:previous_token] || token_record
      token_record = result[:token]
      new_refresh_plain = result[:refresh_token]

      return handle_missing_refresh_token(refresh_public_id) unless token_record.is_a?(token_class)

      # Load resource from token record
      # No special test handling - same code path for all environments
      resource = token_record.public_send(resource_type)

      return handle_inactive_resource(resource, refresh_public_id, token_record) unless resource&.active?

      build_refreshed_session(resource, token_record, new_refresh_plain, previous_token_record: previous_token_record)
    rescue Sign::InvalidRefreshToken => e
      handle_invalid_refresh_token(e, refresh_public_id, token_record)
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
      clear_auth_cookies!

      record_audit(AUDIT_EVENTS[:logged_out], resource: resource) if resource
      reset_session
    end

    def transparent_refresh_access_token
      return if logged_in?

      # Loop guard: prevents infinite refresh loops within the same request
      return if request.env[Auth::IoKeys::Env::AUTH_REFRESHED_FLAG]

      refresh_plain = cookies[REFRESH_COOKIE_KEY]
      return if refresh_plain.blank?

      # Mark as refreshed to prevent recursion
      request.env[Auth::IoKeys::Env::AUTH_REFRESHED_FLAG] = true

      refreshed = refresh_access_token(refresh_plain)
      unless refreshed
        Rails.logger.debug { "[Auth] transparent_refresh: FAILURE" }
        clear_auth_cookies!
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
      return Auth::IoKeys::Headers::TEST_CURRENT_RESOURCE unless Rails.env.test?

      actor_type = resource_type if respond_to?(:resource_type, true)
      case actor_type
      when "user"
        Auth::IoKeys::Headers::TEST_CURRENT_USER
      when "staff"
        Auth::IoKeys::Headers::TEST_CURRENT_STAFF
      when "viewer"
        Auth::IoKeys::Headers::TEST_CURRENT_VIEWER
      else
        Auth::IoKeys::Headers::TEST_CURRENT_RESOURCE
      end
    rescue StandardError
      Auth::IoKeys::Headers::TEST_CURRENT_RESOURCE
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
      include ::Sign::ErrorResponses
      include ::SessionLimitGate

      if respond_to?(:helper_method)
        helper_method :current_account, :current_session_public_id, :current_session_restricted?
      end
    end

    # ==========================================================================
    # 5) Abstract contract & policy DSL (controller class API)
    # ==========================================================================
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
    # 6) Private request/cookie/token I/O helpers
    # ======================================================================

    # ----------------------------------------------------------------------
    # 6-1) Withdrawal gate (Request I/O boundary)
    # ----------------------------------------------------------------------

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
        edit_sign_app_configuration_path(ri: params[Auth::IoKeys::Params::RI])
      elsif respond_to?(:edit_sign_org_configuration_path, true)
        edit_sign_org_configuration_path(ri: params[Auth::IoKeys::Params::RI])
      else
        "/configuration/edit"
      end
    rescue StandardError => e
      Rails.logger.error("Failed to resolve configuration edit path: #{e.message}")
      "/configuration/edit"
    end

    # ----------------------------------------------------------------------
    # 6-2) Cookie/session/header accessors (I/O boundary)
    # ----------------------------------------------------------------------
    def cookie_options
      Core::CookieOptions.for(
        surface: Core::Surface.current(request),
        request: request,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        path: "/",
      )
    end

    def cookie_deletion_options
      Core::CookieOptions.for(
        surface: Core::Surface.current(request),
        request: request,
        same_site: :lax,
        path: "/",
      ).except(:expires, :httponly, :secure, :same_site)
    end

    def device_cookie_key
      Auth::CookieName.device(refresh_cookie_key: REFRESH_COOKIE_KEY)
    end

    def device_cookie_options
      cookie_options.merge(expires: REFRESH_TOKEN_TTL.from_now)
    end

    def set_device_id_cookie!(device_id)
      cookies.encrypted[device_cookie_key] = device_cookie_options.merge(value: device_id)
    end

    def clear_device_id_cookie!
      cookies.delete(device_cookie_key, cookie_deletion_options)
    end

    def clear_auth_cookies!
      cookies.delete ACCESS_COOKIE_KEY, cookie_deletion_options
      cookies.delete REFRESH_COOKIE_KEY, cookie_deletion_options
      clear_device_id_cookie!
      @current_resource = nil
    end

    def read_device_id_cookie
      cookies.encrypted[device_cookie_key].to_s.presence
    end

    def set_auth_cookies(access_token:, refresh_token:, device_id:)
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
      set_device_id_cookie!(device_id)
    end

    def extract_access_token(cookie_key)
      return nil unless respond_to?(:request, true) && request

      auth_header = request.headers[Auth::IoKeys::Headers::AUTHORIZATION]
      if auth_header.present?
        prefix, token = auth_header.split(" ", 2)
        return token if prefix.casecmp("Bearer").zero? && token.present?
      end

      cookies[cookie_key]
    end

    # ----------------------------------------------------------------------
    # 6-3) Audit/occurrence writing (side-effect boundary)
    # ----------------------------------------------------------------------
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

    def write_refresh_occurrence(event_type:, token_record:, reason:, device_source:)
      model_class = occurrence_model_class
      return unless model_class

      body = SecureRandom.uuid
      token_record_id = token_record&.public_id

      model_class.create!(
        body: body,
        event_type: event_type,
        status_id: 1,
        context: {
          host: request.host,
          request_id: request.request_id,
          ip_hash: occurrence_ip_hash,
          device_source: device_source,
          token_family_id: token_record&.refresh_token_family_id,
          token_id: token_record_id,
          generation: token_record&.refresh_token_generation,
          reason: reason,
        },
      )
    rescue StandardError => e
      Rails.event.notify(
        "#{resource_type}.occurrence.write_failed",
        event_type: event_type,
        reason: reason,
        error_class: e.class.name,
        error_message: e.message,
      )
    end

    def occurrence_model_class
      return UserOccurrence if resource_type == "user"
      return StaffOccurrence if resource_type == "staff"

      nil
    end

    def occurrence_ip_hash
      ip = request_ip_address.to_s
      secret = ENV["OCCURRENCE_HMAC_SECRET"].presence || Rails.application.secret_key_base
      OpenSSL::HMAC.hexdigest("SHA256", secret, ip)
    end

    # ----------------------------------------------------------------------
    # 6-4) Refresh error handling and token/device guards
    # ----------------------------------------------------------------------
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
        next if token_record.blank?

        now = Time.current
        family_id = token_record.refresh_token_family_id.to_s
        if family_id.present?
          token_record.class.where(refresh_token_family_id: family_id, revoked_at: nil)
            .update_all(revoked_at: now, updated_at: now)
        elsif token_record.revoked_at.nil?
          token_record.update!(revoked_at: now)
        end
      end
      nil
    end

    def build_refreshed_session(resource, token_record, new_refresh_plain, previous_token_record: nil)
      new_access_token = Token.encode(
        resource,
        host: request.host,
        session_public_id: token_record.public_id,
        resource_type: resource_type,
      )

      set_auth_cookies(
        access_token: new_access_token,
        refresh_token: new_refresh_plain,
        device_id: token_record.device_id,
      )

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
        old_refresh_token_id: previous_token_record&.public_id || token_record.public_id,
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

    def handle_invalid_refresh_token(exception, refresh_public_id, token_record = nil)
      set_refresh_failure!(:unauthorized, "invalid_refresh_token")

      if exception.message == "refresh_token_reuse_detected"
        write_refresh_occurrence(
          event_type: "refresh_reuse_detected",
          token_record: token_record || find_refresh_token_record(refresh_public_id),
          reason: "reuse",
          device_source: refresh_device_source,
        )
      end

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

    def handle_refresh_device_denied(token_record, refresh_public_id)
      reason = @refresh_device_reason || "missing"
      event_type = (reason == "mismatch") ? "refresh_device_mismatch" : "refresh_device_missing"
      write_refresh_occurrence(
        event_type: event_type,
        token_record: token_record,
        reason: reason,
        device_source: refresh_device_source,
      )

      set_refresh_failure!(:unauthorized, "invalid_refresh_token")
      destroy_refresh_token_from_cookie
      clear_auth_cookies!

      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_public_id,
        reason: "device_#{reason}",
        ip_address: request_ip_address,
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

      find_logic = -> { token_class.find_by(public_id: refresh_public_id) }
      TokenRecord.connected_to(role: :reading, &find_logic)
    end

    def set_refresh_failure!(status, code)
      @refresh_failure_status = status
      @refresh_failure_code = code
    end

    def clear_refresh_failure!
      @refresh_failure_status = nil
      @refresh_failure_code = nil
      @refresh_device_reason = nil
    end

    def refresh_device_allowed?(token_record)
      header_device_id = request.headers[Auth::IoKeys::Headers::DEVICE_ID].to_s.presence
      cookie_device_id = read_device_id_cookie

      if header_device_id.blank? && cookie_device_id.blank?
        # In test environment, allow missing device ID to simplify tests
        # ONLY if not explicitly requested via a strict-check header.
        if Rails.env.test? && request.headers[Auth::IoKeys::Headers::STRICT_DEVICE_CHECK].blank?
          return true
        end

        @refresh_device_reason = "missing"
        return false
      end

      if header_device_id.present? && cookie_device_id.present? && header_device_id != cookie_device_id
        @refresh_device_reason = "mismatch"
        return false
      end

      extracted_device_id = header_device_id || cookie_device_id
      return true if token_record.blank?

      token_device_id = token_record.device_id.to_s
      if token_device_id.blank? || token_device_id != extracted_device_id
        @refresh_device_reason = "mismatch"
        return false
      end

      true
    end

    def refresh_device_source
      header_present = request.headers[Auth::IoKeys::Headers::DEVICE_ID].to_s.present?
      cookie_present = read_device_id_cookie.present?
      return "both" if header_present && cookie_present
      return "header" if header_present
      return "cookie" if cookie_present

      "none"
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

      header_key = test_header_key
      test_id = request.headers[header_key]
      if test_id.blank? && header_key == Auth::IoKeys::Headers::TEST_CURRENT_RESOURCE
        test_id = request.headers[Auth::IoKeys::Headers::TEST_CURRENT_RESOURCE] ||
          request.headers[Auth::IoKeys::Headers::TEST_CURRENT_USER] ||
          request.headers[Auth::IoKeys::Headers::TEST_CURRENT_STAFF] ||
          request.headers[Auth::IoKeys::Headers::TEST_CURRENT_VIEWER]
      end
      return nil unless test_id

      resource = resource_class.find_by(id: test_id)
      if resource
        @bypass_withdrawn_check = true
        test_session_id = request.headers[Auth::IoKeys::Headers::TEST_SESSION_PUBLIC_ID]
        @current_session_public_id = test_session_id if test_session_id.present?
      end
      resource
    end

    def load_from_token
      access_token = extract_access_token(ACCESS_COOKIE_KEY)
      request_host = request&.host
      return nil if request_host.blank?

      result = Auth::CurrentResourceResolver.new(
        access_token: access_token,
        request_host: request_host,
        resource_type: resource_type,
        resource_class: resource_class,
        token_class: token_class,
        test_env: Rails.env.test?,
      ).call

      emit_actor_mismatch_event(result.payload) if result.failure_reason == :actor_mismatch
      @current_session_public_id = result.session_public_id if result.session_public_id.present?
      result.resource
    end

    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def emit_actor_mismatch_event(payload)
      act = Token.extract_act(payload)
      sub = Token.extract_subject(payload)

      Rails.event.notify(
        "authentication.actor_mismatch",
        expected: resource_type,
        actual: act,
        subject: sub,
        ip_address: request_ip_address,
      )

      Sign::Risk::Emitter.emit(
        "actor_mismatch",
        user_id: sub,
        ip: request&.remote_ip,
        user_agent: request&.user_agent,
        request_id: request&.request_id,
        meta: { expected: resource_type, actual: act },
      )
    end

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

    # Handles session expiry by redirecting with appropriate message
    #
    # @param redirect_path [String, Symbol] Where to redirect
    # @param message_key [String] Translation key for the expiry message
    def handle_session_expiry(redirect_path, message_key)
      redirect_params = { notice: t(message_key) }
      # Preserve redirect parameter if present
      default_rd_key = Auth::IoKeys::Session::DEFAULT_RD
      redirect_params[Auth::IoKeys::Params::RD] = session[default_rd_key] if session[default_rd_key].present?
      redirect_to redirect_path, redirect_params
    end

    # ======================================================================
    # 7) Policy/domain decisions
    # ======================================================================
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

    # ----------------------------------------------------------------------
    # 7-1) MFA/session-limit domain decisions
    # ----------------------------------------------------------------------
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

    # Default redirect destination after login for guest_only! policy.
    # Override in controllers to customize (e.g. to preserve ri parameter).
    def after_login_path
      default_after_login_path
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

    # ======================================================================
    # 8) Session/MFA helper reads + response shapers
    # ======================================================================
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

      safe_internal_path(candidate)
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
      redirect_to(path, allow_other_host: false, alert: message)
    end
  end
end
