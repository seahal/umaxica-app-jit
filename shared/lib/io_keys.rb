# typed: false
# frozen_string_literal: true

module Auth
  module IoKeys
    HOST_COOKIE_PREFIX = "__Host-"
    
    module Cookies
      ACCESS_BASENAME = "auth_access"
      REFRESH_BASENAME = "auth_refresh"
      DEVICE_BASENAME = "auth_device_id"
      DBSC_BASENAME = "auth_dbsc"
    end

    module Headers
      AUTHORIZATION = "Authorization"
      DEVICE_ID = "X-Device-Id"
      DBSC_REGISTRATION = "Sec-Session-Registration"
      DBSC_CHALLENGE = "Sec-Session-Challenge"
      DBSC_SESSION_ID = "Sec-Session-Id"
      DBSC_RESPONSE = "Sec-Session-Response"
      TEST_BULLETIN = "X-TEST-BULLETIN"
      TEST_CURRENT_RESOURCE = "X-TEST-CURRENT-RESOURCE"
      TEST_CURRENT_USER = "X-TEST-CURRENT-USER"
      TEST_CURRENT_STAFF = "X-TEST-CURRENT-STAFF"
      TEST_CURRENT_VIEWER = "X-TEST-CURRENT-VIEWER"
      TEST_SESSION_PUBLIC_ID = "X-TEST-SESSION-PUBLIC-ID"
    end

    module Params
      RD = :rd
      RI = :ri
    end

    module Session
      DEFAULT_RD = :user_email_authentication_rd
      BULLETIN = :auth_bulletin
    end

    module Env
      AUTH_REFRESHED_FLAG = "jit.auth.refreshed"
    end
  end
end

module Preference
  module IoKeys
    SECURE_COOKIE_PREFIX = "__Secure-"

    module Cookies
      THEME = "ct"
      LANGUAGE = "language"
      TIMEZONE = "tz"
      ACCESS_BASENAME = "preference_access"
      REFRESH_BASENAME = "preference_refresh"
      DEVICE_BASENAME = "preference_device_id"
      DBSC_BASENAME = "preference_dbsc"
      CONSENTED = "consented"
    end

    module Headers
      DEVICE_ID = "X-Device-Id"
      DBSC_REGISTRATION = "Sec-Session-Registration"
      DBSC_CHALLENGE = "Sec-Session-Challenge"
      DBSC_SESSION_ID = "Sec-Session-Id"
      DBSC_RESPONSE = "Sec-Session-Response"
    end

    module Params
      CT = :ct
      LX = :lx
      TZ = :tz
      RI = :ri
      OPTION_ID = :option_id
      REFRESH_TOKEN = :refresh_token
    end
  end
end
