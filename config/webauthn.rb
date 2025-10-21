# config/initializers/webauthn.rb
WebAuthn.configure do |config|
  config.origin = "http://localhost:3000" # HTTP is acceptable during development
  config.rp_id = "localhost"
  config.rp_name = "UMAXICA"
end
