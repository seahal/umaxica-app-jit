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
