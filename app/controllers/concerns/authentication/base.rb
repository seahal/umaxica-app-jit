# frozen_string_literal: true

module Authentication
  module Base
    JWT_ALGORITHM = "ES256"
    ACCESS_TOKEN_EXPIRY = 15.minutes

    def logged_in?
      raise NotImplementedError, "logged_in? must be implemented in including module"
    end

    def log_in(resource)
      # StaffToken or UserToken
      raise NotImplementedError, "log_in must be implemented in including module"
    end

    def log_out
      raise NotImplementedError, "log_out must be implemented in including module"
    end

    def authenticate_user!
      raise NotImplementedError, "authenticate_user! must be implemented in including module"
    end

    def authenticate_staff!
      raise NotImplementedError, "authenticate_staff! must be implemented in including module"
    end

    def generate_access_token(resource)
      raise ArgumentError, "resource cannot be nil" if resource.nil?
      raise ArgumentError, "resource must respond to :id" unless resource.respond_to?(:id)
      raise ArgumentError, "resource id cannot be blank" if resource.id.blank?

      payload = {
        iat: Time.current.to_i,
        exp: ACCESS_TOKEN_EXPIRY.from_now.to_i,
        jti: SecureRandom.uuid,
        iss: request.host,
        aud: "umaxica-api",
        sub: resource.id,
        type: resource.class.name.downcase
      }

      JWT.encode(payload, JwtConfig.private_key, JWT_ALGORITHM)
    rescue StandardError => e
      Rails.event.notify("authentication.token.generation.failed",
                         error_class: e.class.name,
                         error_message: e.message,
                         backtrace: e.backtrace.first(5),
                         resource_type: resource.class.name,
                         resource_id: resource.id
      )
      raise "Access token generation failed"
    end

    def verify_access_token(token)
      raise ArgumentError, "Token cannot be blank" if token.blank?

      JWT.decode(token, JwtConfig.public_key, true, {
        algorithms: [ JWT_ALGORITHM ],
        verify_iat: true,
        verify_exp: true,
        verify_iss: true,
        iss: request.host,
        verify_aud: true,
        aud: "umaxica-api"
      }).first
    rescue JWT::ExpiredSignature
      Rails.event.notify("authentication.token.verification.expired",
                         host: request.host
      )
      raise JWT::ExpiredSignature, "Token has expired"
    rescue JWT::DecodeError, JWT::VerificationError => e
      Rails.event.notify("authentication.token.verification.failed",
                         error_class: e.class.name,
                         host: request.host
      )
      raise JWT::VerificationError, "Invalid token"
    rescue StandardError => e
      Rails.event.notify("authentication.token.verification.error",
                         error_class: e.class.name,
                         error_message: e.message,
                         host: request.host
      )
      raise JWT::VerificationError, "Token verification failed"
    end

    private

    def cookie_options
      opts = {
        httponly: true,
        secure: Rails.env.production?,
        samesite: :strict
      }
      opts[:domain] = shared_cookie_domain if shared_cookie_domain
      opts
    end

    def cookie_deletion_options
      shared_cookie_domain ? { domain: shared_cookie_domain } : {}
    end

    def shared_cookie_domain
      @shared_cookie_domain ||= begin
                                  configured = ENV["AUTH_COOKIE_DOMAIN"]&.strip
                                  return formatted_domain(configured) if configured.present?

                                  derived = derive_cookie_domain_from_host
                                  formatted_domain(derived)
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

    # Extract access token from Authorization header (Bearer token) or Cookie
    # Priority: Authorization header > Cookie
    def extract_access_token(cookie_key)
      # 1. Check Authorization header (Bearer token)
      if request.headers["Authorization"]&.match(/^Bearer\s+(.+)$/i)
        return Regexp.last_match(1)
      end

      # 2. Fallback to Cookie (traditional approach)
      cookies[cookie_key]
    end
  end
end
