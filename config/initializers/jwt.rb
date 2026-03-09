# typed: false
# frozen_string_literal: true

module JwtConfig
  def self.private_key
    private_key_base64 = Rails.app.creds.require(:JWT_AUTH_PRIVATE_KEY)

    private_key_der = Base64.decode64(private_key_base64)
    OpenSSL::PKey::EC.new(private_key_der)
  end

  def self.public_key
    public_key_base64 = Rails.app.creds.require(:JWT_AUTH_PUBLIC_KEY)

    public_key_der = Base64.decode64(public_key_base64)
    OpenSSL::PKey::EC.new(public_key_der)
  end
end
