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

    def authenticate!
      raise NotImplementedError, "authenticate! must be implemented in including module"
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

      key = jwt_private_key

      JWT.encode(payload, key, JWT_ALGORITHM)
    rescue StandardError => e
      Rails.logger.error "Failed to generate access token: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      raise "Access token generation failed: #{e.message}"
    end

    def verify_access_token(token)
      raise ArgumentError, "Token cannot be blank" if token.blank?

      key = jwt_public_key
      JWT.decode(token, key, true, {
        algorithm: JWT_ALGORITHM,
        verify_iat: true,
        verify_exp: true,
        verify_iss: true,
        iss: request.host,
        verify_aud: true,
        aud: "umaxica-api"
      }).first
    rescue JWT::ExpiredSignature
      Rails.logger.info "Expired token verification attempt"
      raise JWT::ExpiredSignature, "Token has expired"
    rescue JWT::DecodeError, JWT::VerificationError => e
      Rails.logger.warn "Token verification failed: #{e.class.name}"
      raise JWT::VerificationError, "Invalid token"
    rescue StandardError => e
      Rails.logger.error "Unexpected error during token verification: #{e.message}"
      raise JWT::VerificationError, "Token verification failed"
    end

    private

    def jwt_private_key
      @jwt_private_key ||= begin
                             private_key_base64 = ENV["JWT_PRIVATE_KEY"] || Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
                             raise "JWT private key not configured in credentials" if private_key_base64.blank?

                             private_key_der = Base64.decode64(private_key_base64)
                             OpenSSL::PKey::EC.new(private_key_der)
                           end
    end

    def jwt_public_key
      @jwt_public_key ||= begin
                            public_key_base64 = ENV["JWT_PUBLIC_KEY"] || Rails.application.credentials.dig(:JWT, :PUBLIC_KEY)
                            raise "JWT public key not configured in credentials" if public_key_base64.blank?

                            public_key_der = Base64.decode64(public_key_base64)
                            OpenSSL::PKey::EC.new(public_key_der)
                          end
    end

    def cookie_options
      opts = {
        httponly: true,
        secure: Rails.env.production?,
        samesite: :lax
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
  end
end
