# frozen_string_literal: true

require "jwt"

module Auth
  module Base
    extend ActiveSupport::Concern

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
    ACCESS_COOKIE_KEY = Rails.env.production? ? "__Secure-auth_access" : "auth_access"
    REFRESH_COOKIE_KEY = Rails.env.production? ? "__Secure-auth_refresh" : "auth_refresh"

    # Token TTLs
    ACCESS_TOKEN_TTL = ENV.fetch("AUTH_ACCESS_TOKEN_TTL", 1.hour.to_i).to_i.seconds
    REFRESH_TOKEN_TTL = 30.days

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

    def log_in(resource, record_login_audit: true, token_kind_id: "BROWSER_WEB", require_totp_check: true)
      if require_totp_check && resource.respond_to?(:totp_enabled?) && resource.totp_enabled?
        session[:mfa_user_id] = resource.id
        return { status: :totp_required }
      end

      reset_session

      token_record =
        TokenRecord.connected_to(role: :writing) do
          token_attributes = { resource_foreign_key => resource.id }
          # Determine kind column based on resource type (user_token_kind_id or staff_token_kind_id)
          kind_column = "#{resource_type}_token_kind_id"
          token_attributes[kind_column] = token_kind_id if token_class.column_names.include?(kind_column)

          token_class.create!(token_attributes)
        end

      # Generate SHA3-based refresh token
      refresh_plain = token_record.rotate_refresh_token!

      # Generate JWT access token with explicit resource_type
      access_token = Token.encode(
        resource,
        host: request.host,
        session_public_id: token_record.public_id,
        resource_type: resource_type,
      )

      # Always set cookies (even for JSON responses - required for Edge/SPA)
      set_auth_cookies(access_token: access_token, refresh_token: refresh_plain)

      record_audit(AUDIT_EVENTS[:logged_in], resource: resource) if record_login_audit

      {
        status: :success,
        access_token: access_token,
        refresh_token: refresh_plain,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_TTL.to_i,
      }
    end

    def refresh_access_token(refresh_plain)
      refresh_public_id, = token_class.parse_refresh_token(refresh_plain.to_s)
      result = Sign::RefreshTokenService.call(refresh_token: refresh_plain)
      token_record = result[:token]
      new_refresh_plain = result[:refresh_token]

      unless token_record.is_a?(token_class)
        Rails.event.notify(
          "#{resource_type}.token.refresh.failed",
          refresh_token_id: refresh_public_id,
          reason: "token_not_found",
          ip_address: request_ip_address,
        )
        return nil
      end

      resource = token_record.public_send(resource_type)

      unless resource&.active?
        Rails.event.notify(
          "#{resource_type}.token.refresh.failed",
          "#{resource_type}_id": resource&.id,
          refresh_token_id: refresh_public_id,
          reason: "#{resource_type}_inactive",
          ip_address: request_ip_address,
        )
        TokenRecord.connected_to(role: :writing) { token_record.destroy! }
        return nil
      end

      new_access_token = Token.encode(
        resource,
        host: request.host,
        session_public_id: token_record.public_id,
        resource_type: resource_type,
      )

      # Always set cookies (even for JSON responses - required for Edge/SPA)
      set_auth_cookies(access_token: new_access_token, refresh_token: new_refresh_plain)

      Rails.event.notify(
        "#{resource_type}.token.refreshed",
        "#{resource_type}_id": resource.id,
        old_refresh_token_id: token_record.public_id,
        new_refresh_token_id: token_record.public_id,
        ip_address: request_ip_address,
      )
      record_audit(AUDIT_EVENTS[:token_refreshed], resource: resource)

      {
        access_token: new_access_token,
        refresh_token: new_refresh_plain,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_TTL.to_i,
      }
    rescue Sign::InvalidRefreshToken => e
      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_public_id,
        reason: e.class.name,
        ip_address: request_ip_address,
      )
      nil
    rescue StandardError => e
      Rails.event.notify(
        "#{resource_type}.token.refresh.error",
        "#{resource_type}_id": resource&.id,
        refresh_token_id: refresh_public_id,
        error_class: e.class.name,
        error_message: e.message,
        ip_address: request_ip_address,
      )
      nil
    end

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

      refresh_plain = cookies[REFRESH_COOKIE_KEY]
      return if refresh_plain.blank?

      refreshed = refresh_access_token(refresh_plain)
      return unless refreshed

      remove_instance_variable(:@current_resource) if defined?(@current_resource)
    end

    def authenticate!
      return if logged_in?

      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
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
      # Important: prepend first so this runs before other before_action hooks.
      prepend_before_action :enforce_access_policy! if respond_to?(:prepend_before_action)
      helper_method :current_account, :current_session_public_id if respond_to?(:helper_method)
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
        filters = filters.flatten
        filters.map!(&:to_sym)
        if filters.include?(:enforce_access_policy!)
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

      audit = audit_class.new(
        actor: actor,
        event_id: event_id,
        ip_address: request_ip_address,
        occurred_at: Time.current,
      )
      audit.public_send("#{resource_type}=", resource)
      audit.save!
    end

    def request_ip_address
      (respond_to?(:request, true) && request) ? request.remote_ip : nil
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
      @bypass_withdrawn_check = true if resource
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
          check_logic.call
        else
          TokenRecord.connected_to(role: :reading, &check_logic)
        end
      return nil unless token_exists

      @current_session_public_id = sid

      resource_class.find_by(id: Token.extract_subject(payload))
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
      rule = resolve_access_policy_for(action_name)

      if rule.nil?
        Rails.logger.warn "AUTH_POLICY: Missing for #{self.class.name}##{action_name}"
        raise MissingPolicyError,
              "Missing access_policy for #{self.class.name}##{action_name}. " \
              "Declare one of: #{VALID_POLICIES.join(", ")}"
      end

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
        status = options[:status] || :unauthorized
        render json: { error: (options[:message] || "unauthorized") }, status: status
      else
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
    end

    def enforce_guest_only!(options = {})
      # Guest-only policy: block logged-in users.
      return true unless respond_to?(:logged_in?) && logged_in?

      if request.format.json? || options[:request_format] == :json
        status = options[:status] || :forbidden
        render json: { error: (options[:message] || "already_authenticated") }, status: status
      else
        if options[:status] == :unauthorized
          return render plain: (options[:message] || "権限がありません"), status: :unauthorized
        end
        if options[:status] == :bad_request
          return render plain: (options[:message] || "リクエストが不正です"), status: :bad_request
        end

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
end
