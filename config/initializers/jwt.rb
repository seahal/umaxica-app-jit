# typed: false
# frozen_string_literal: true

module JwtConfig
  def self.private_key
    Jit::Security::Jwt::Keyring.private_key_for_active
  end

  def self.public_key
    Jit::Security::Jwt::Keyring.public_key_for_active
  end
end
