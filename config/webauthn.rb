# config/initializers/webauthn.rb
WebAuthn.configure do |config|
  config.origin  = "http://localhost:3000"   # 開発中は http でもOK
  config.rp_id   = "localhost"
  config.rp_name = "MyApp"
end
