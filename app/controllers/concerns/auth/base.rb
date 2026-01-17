# frozen_string_literal: true

require "jwt"

module Auth
  module Base
    extend ActiveSupport::Concern

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
            "jti" => Jwt::Jti.generate,
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

    def current_resource
      return @current_resource if defined?(@current_resource)

      @current_resource = load_current_resource
    end

    def log_in(resource, record_login_audit: true)
      reset_session

      token_record =
        TokenRecord.connected_to(role: :writing) do
          token_class.create!(resource_foreign_key => resource.id)
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
        access_token: access_token,
        refresh_token: refresh_plain,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_TTL.to_i,
      }
    end

    def refresh_access_token(refresh_plain)
      result = Sign::RefreshTokenService.call(refresh_token: refresh_plain)
      token_record = result[:token]
      new_refresh_plain = result[:refresh_token]

      unless token_record.is_a?(token_class)
        Rails.event.notify(
          "#{resource_type}.token.refresh.failed",
          refresh_token_id: refresh_plain,
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
          refresh_token_id: refresh_plain,
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
        new_refresh_token_id: new_refresh_plain,
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
        refresh_token_id: refresh_plain,
        reason: e.class.name,
        ip_address: request_ip_address,
      )
      nil
    rescue StandardError => e
      Rails.event.notify(
        "#{resource_type}.token.refresh.error",
        "#{resource_type}_id": resource&.id,
        refresh_token_id: refresh_plain,
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

    private

    def cookie_options
      opts = {
        httponly: true,
        secure: Rails.env.production?,
        samesite: :lax,
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

      token_class.find_by(public_id: public_id)&.destroy
    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.event.notify(
        "#{resource_type}.token.destroy.failed",
        token_id: token_value,
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
  end
end
