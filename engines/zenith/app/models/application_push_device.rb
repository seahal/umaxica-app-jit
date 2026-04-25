# typed: false
# frozen_string_literal: true

class ApplicationPushDevice < ActionPushNative::Device
  # Customize TokenError handling (default: destroy!)
  # rescue_from (ActionPushNative::TokenError) { Rails.event.error("push_device.invalid_token", device_id: id) }
end
