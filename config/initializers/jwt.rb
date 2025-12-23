module JwtConfig
  def self.private_key
    private_key_base64 = ENV["JWT_PRIVATE_KEY"] || Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
    raise "JWT private key not configured in credentials" if private_key_base64.blank?

    private_key_der = Base64.decode64(private_key_base64)
    OpenSSL::PKey::EC.new(private_key_der)
  end

  def self.public_key
    public_key_base64 = ENV["JWT_PUBLIC_KEY"] || Rails.application.credentials.dig(:JWT, :PUBLIC_KEY)
    raise "JWT public key not configured in credentials" if public_key_base64.blank?

    public_key_der = Base64.decode64(public_key_base64)
    OpenSSL::PKey::EC.new(public_key_der)
  end
end
