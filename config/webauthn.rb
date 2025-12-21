# config/initializers/webauthn.rb
WebAuthn.configure do |config|
  config.allowed_origins = [ "https://sign.umaxica.app", "https://sign.umaxica.org" ]
  config.rp_name = "UMAXICA"
end
