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
      Rails.logger.error "Failed to generate access token: #{e.message}"
      raise "Access token generation failed"
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
                             private_key_base64 = ENV[:JWT_PUBLIC_KEY] || Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
                             raise "JWT private key not configured in credentials" if private_key_base64.blank?

                             private_key_der = Base64.decode64(private_key_base64)
                             OpenSSL::PKey::EC.new(private_key_der)
                           end
    end

    def jwt_public_key
      @jwt_public_key ||= begin
                            public_key_base64 = ENV[:JWT_PRIVATE_KEY] || Rails.application.credentials.dig(:JWT, :PUBLIC_KEY)
                            raise "JWT public key not configured in credentials" if public_key_base64.blank?

                            public_key_der = Base64.decode64(public_key_base64)
                            OpenSSL::PKey::EC.new(public_key_der)
                          end
    end
  end
end
