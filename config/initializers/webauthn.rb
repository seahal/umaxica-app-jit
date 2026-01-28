# frozen_string_literal: true

WebAuthn.configure do |config|
  # rp_id and origin are now determined dynamically per request host
  # config.rp_id and config.origin are NOT set globally here.
  config.rp_name = ENV.fetch("WEBAUTHN_RP_NAME", "Umaxica")
end
