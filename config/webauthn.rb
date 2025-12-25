# config/initializers/webauthn.rb
WebAuthn.configure do |config|
  config.allowed_origins = [ "https://auth.umaxica.app", "https://auth.umaxica.org" ]
  config.rp_name = "UMAXICA"
end
