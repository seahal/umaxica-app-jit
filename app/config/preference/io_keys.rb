# typed: false
# frozen_string_literal: true

module Preference
  module IoKeys
    SECURE_COOKIE_PREFIX = "__Secure-"

    module Cookies
      THEME = "jit_ct"
      LEGACY_THEME = "ct"
      LANGUAGE = "jit_lx"
      TIMEZONE = "jit_tz"
      CONSENTED = "jit_preference_consented"
      ACCESS_BASENAME = "jit_preference_access"
      REFRESH_BASENAME = "jit_preference_refresh"
      DBSC_BASENAME = "jit_preference_dbsc"
      DEVICE_BASENAME = "jit_preference_device_id"
    end

    module Headers
      DEVICE_ID = "X-Device-Id"
      DBSC_REGISTRATION = "Secure-Session-Registration"
      DBSC_CHALLENGE = "Secure-Session-Challenge"
      DBSC_SESSION_ID = "Sec-Secure-Session-Id"
      DBSC_RESPONSE = "Secure-Session-Response"
    end

    module Params
      CT = :ct
      LX = :lx
      RI = :ri
      TZ = :tz
      REFRESH_TOKEN = :refresh_token
      OPTION_ID = :option_id
    end
  end
end
