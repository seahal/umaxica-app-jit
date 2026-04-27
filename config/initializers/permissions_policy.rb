# typed: false
# frozen_string_literal: true

# Define an application-wide HTTP Permissions-Policy header.
# See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy

# WebAuthn directives are not yet supported by Rails' PermissionsPolicy out of the box.
# We extend it here to allow configuring these directives.
ActionDispatch::PermissionsPolicy.class_eval do
  define_method(:publickey_credentials_get) do |*sources|
    @directives["publickey-credentials-get"] = apply_mappings(sources)
  end

  define_method(:publickey_credentials_create) do |*sources|
    @directives["publickey-credentials-create"] = apply_mappings(sources)
  end
end

Rails.application.config.permissions_policy do |f|
  f.accelerometer(:none)
  f.camera(:none)
  f.geolocation(:none)
  f.gyroscope(:none)
  f.magnetometer(:none)
  f.microphone(:none)
  f.midi(:none)
  f.usb(:none)
  f.fullscreen(:self)
  f.payment(:none)

  # Allow WebAuthn for our authentication domains
  f.publickey_credentials_get(:self, "https://id.umaxica.app", "https://id.umaxica.com", "https://id.umaxica.org")
  f.publickey_credentials_create(:self, "https://id.umaxica.app", "https://id.umaxica.com", "https://id.umaxica.org")
end
