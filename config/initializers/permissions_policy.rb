# typed: false
# frozen_string_literal: true

# config/initializers/permissions_policy.rb

Rails.application.config.permissions_policy do |policy|
  policy.accelerometer(:none)
  policy.camera(:none)
  policy.geolocation(:none)
  policy.gyroscope(:none)
  policy.magnetometer(:none)
  policy.microphone(:none)
  policy.midi(:none)
  policy.usb(:none)

  policy.fullscreen(:self)
  policy.payment(:self)
  policy.picture_in_picture(:self)

  # WebAuthn/passkeys require these directives.
  # Rails does not yet define them in DIRECTIVES, so set them directly.
  policy.directives["publickey-credentials-get"]    = ["'self'"]
  policy.directives["publickey-credentials-create"] = ["'self'"]
end
