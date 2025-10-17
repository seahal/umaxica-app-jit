# frozen_string_literal: true

Rails.application.config.permissions_policy do |policy|
  # Hardened baseline: explicitly disable high-risk features unless required.
  policy.accelerometer             :none
  policy.ambient_light_sensor      :none
  policy.autoplay                  :none
  policy.camera                    :self
  policy.display_capture           :none
  policy.encrypted_media           :none
  policy.fullscreen                :self
  policy.geolocation               :none
  policy.gyroscope                 :none
  policy.magnetometer              :none
  policy.microphone                :none
  policy.midi                      :none
  policy.payment                   :self
  policy.picture_in_picture        :none
  policy.screen_wake_lock          :none
  policy.serial                    :none
  policy.usb                       :none
  policy.web_share                 :self
  policy.sync_xhr                  :self
end
