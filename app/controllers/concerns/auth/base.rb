# frozen_string_literal: true

require "jwt"

module Auth
  module Base
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
      ACCESS_TOKEN_TTL = 15.minutes

      class << self
        def encode(resource, host:, session_public_id: nil)
          return nil unless valid_encode_params?(resource, host)

          payload = build_payload(resource, session_public_id)
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

        def build_payload(resource, session_public_id)
          now = Time.current

          payload = {
            "iat" => now.to_i,
            "exp" => (now + ACCESS_TOKEN_TTL).to_i,
            "jti" => Jwt::Jti.generate,
            "iss" => JwtConfiguration.issuer,
            "aud" => JwtConfiguration.audiences,
            "sub" => resource.id,
            "type" => resource.class.name.downcase,
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

      if Rails.env.test? && respond_to?(:request, true) && request
        test_id = request.headers[test_header_key]
        if test_id
          @current_resource = resource_class.find_by(id: test_id)
          @bypass_withdrawn_check = true
          return @current_resource
        end
      end

      access_token = extract_access_token(self.class::ACCESS_COOKIE_KEY)
      return nil if access_token.blank?

      payload = Token.decode(access_token, host: request.host)
      return nil if payload.blank?
      return nil unless Token.extract_type(payload) == resource_type

      @current_resource = resource_class.find_by(id: Token.extract_subject(payload))
      if @current_resource&.respond_to?(:withdrawn?) &&
          @current_resource.withdrawn? &&
          !@bypass_withdrawn_check
        @current_resource = nil
      end

      @current_resource
    end

    def log_in(resource, record_login_audit: true)
      reset_session

      token =
        TokenRecord.connected_to(role: :writing) do
          token_class.create!(resource_foreign_key => resource.id)
        end
      refresh_token = token.rotate_refresh_token!
      credentials = Token.encode(resource, host: request.host, session_public_id: token.public_id)

      unless request.format.json?
        cookies[self.class::ACCESS_COOKIE_KEY] = cookie_options.merge(
          value: credentials,
          expires: Token::ACCESS_TOKEN_TTL.from_now,
        )
        cookies.encrypted[self.class::REFRESH_COOKIE_KEY] = cookie_options.merge(
          value: refresh_token,
          expires: 1.year.from_now,
        )
      end

      record_audit(AUDIT_EVENTS[:logged_in], resource: resource) if record_login_audit

      {
        access_token: credentials,
        refresh_token: refresh_token,
        token_type: "Bearer",
        expires_in: Token::ACCESS_TOKEN_TTL.to_i,
      }
    end

    def refresh_access_token(refresh_token)
      result = Sign::RefreshTokenService.call(refresh_token: refresh_token)
      old_token = result[:token]

      unless old_token.is_a?(token_class)
        Rails.event.notify(
          "#{resource_type}.token.refresh.failed",
          refresh_token_id: refresh_token,
          reason: "token_not_found",
          ip_address: request_ip_address,
        )
        return nil
      end

      resource = old_token.public_send(resource_type)

      unless resource&.active?
        Rails.event.notify(
          "#{resource_type}.token.refresh.failed",
          "#{resource_type}_id": resource&.id,
          refresh_token_id: refresh_token,
          reason: "#{resource_type}_inactive",
          ip_address: request_ip_address,
        )
        TokenRecord.connected_to(role: :writing) { old_token.destroy! }
        return nil
      end

      new_access_token = Token.encode(resource, host: request.host, session_public_id: old_token.public_id)

      Rails.event.notify(
        "#{resource_type}.token.refreshed",
        "#{resource_type}_id": resource.id,
        old_refresh_token_id: old_token.public_id,
        new_refresh_token_id: result[:refresh_token],
        ip_address: request_ip_address,
      )
      record_audit(AUDIT_EVENTS[:token_refreshed], resource: resource)

      {
        access_token: new_access_token,
        refresh_token: result[:refresh_token],
        token_type: "Bearer",
        expires_in: Token::ACCESS_TOKEN_TTL.to_i,
      }
    rescue Sign::InvalidRefreshToken => e
      Rails.event.notify(
        "#{resource_type}.token.refresh.failed",
        refresh_token_id: refresh_token,
        reason: e.class.name,
        ip_address: request_ip_address,
      )
      nil
    rescue StandardError => e
      Rails.event.notify(
        "#{resource_type}.token.refresh.error",
        "#{resource_type}_id": resource&.id,
        refresh_token_id: refresh_token,
        error_class: e.class.name,
        error_message: e.message,
        ip_address: request_ip_address,
      )
      nil
    end

    def log_out
      resource = current_resource
      token_value = cookies.encrypted[self.class::REFRESH_COOKIE_KEY]
      if token_value
        begin
          public_id, = token_class.parse_refresh_token(token_value)
          token_class.find_by(public_id: public_id)&.destroy if public_id
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.event.notify(
            "#{resource_type}.token.destroy.failed",
            token_id: token_value,
            error_message: e.message,
            ip_address: request_ip_address,
          )
        end
      end
      cookies.delete self.class::ACCESS_COOKIE_KEY, **cookie_deletion_options
      cookies.delete self.class::REFRESH_COOKIE_KEY, **cookie_deletion_options
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
        secure: true,
        samesite: :lax,
      }
      opts[:domain] = shared_cookie_domain if shared_cookie_domain
      opts
    end

    def cookie_deletion_options
      shared_cookie_domain ? { domain: shared_cookie_domain } : {}
    end

    def shared_cookie_domain
      @shared_cookie_domain ||=
        begin
          configured = ENV["SIGN_COOKIE_DOMAIN"]&.strip
          if configured.present?
            formatted_domain(configured)
          else
            derived = derive_cookie_domain_from_host
            formatted_domain(derived)
          end
        end
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
  end
end
