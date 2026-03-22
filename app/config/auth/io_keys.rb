# typed: false
# frozen_string_literal: true

module Auth
  module IoKeys
    SECURE_COOKIE_PREFIX = "__Secure-"

    module Cookies
      ACCESS_BASENAME = "auth_access"
      REFRESH_BASENAME = "auth_refresh"
      DBSC_BASENAME = "auth_dbsc"
      DEVICE_BASENAME = "auth_device_id"

      public_constant :ACCESS_BASENAME
      public_constant :REFRESH_BASENAME
      public_constant :DBSC_BASENAME
      public_constant :DEVICE_BASENAME
    end

    module Headers
      AUTHORIZATION = "Authorization"
      DEVICE_ID = "X-Device-Id"
      DBSC_REGISTRATION = "Secure-Session-Registration"
      DBSC_CHALLENGE = "Secure-Session-Challenge"
      DBSC_SESSION_ID = "Sec-Secure-Session-Id"
      DBSC_RESPONSE = "Secure-Session-Response"
      STRICT_DEVICE_CHECK = "X-STRICT-DEVICE-CHECK"
      TEST_CHECKPOINT = "X-TEST-CHECKPOINT"
      TEST_CURRENT_RESOURCE = "X-TEST-CURRENT-RESOURCE"
      TEST_CURRENT_USER = "X-TEST-CURRENT-USER"
      TEST_CURRENT_STAFF = "X-TEST-CURRENT-STAFF"
      TEST_CURRENT_VIEWER = "X-TEST-CURRENT-VIEWER"
      TEST_SESSION_PUBLIC_ID = "X-TEST-SESSION-PUBLIC-ID"

      public_constant :AUTHORIZATION
      public_constant :DEVICE_ID
      public_constant :DBSC_REGISTRATION
      public_constant :DBSC_CHALLENGE
      public_constant :DBSC_SESSION_ID
      public_constant :DBSC_RESPONSE
      public_constant :STRICT_DEVICE_CHECK
      public_constant :TEST_CHECKPOINT
      public_constant :TEST_CURRENT_RESOURCE
      public_constant :TEST_CURRENT_USER
      public_constant :TEST_CURRENT_STAFF
      public_constant :TEST_CURRENT_VIEWER
      public_constant :TEST_SESSION_PUBLIC_ID
    end

    module Params
      RD = :rd
      RI = :ri
      RT = :rt

      public_constant :RD
      public_constant :RI
      public_constant :RT
    end

    module Session
      DEFAULT_RD = :user_email_authentication_rd
      CHECKPOINT = :in_checkpoint

      public_constant :DEFAULT_RD
      public_constant :CHECKPOINT
    end

    module Env
      AUTH_REFRESHED_FLAG = "auth_refreshed"

      public_constant :AUTH_REFRESHED_FLAG
    end

    public_constant :SECURE_COOKIE_PREFIX
  end
end
