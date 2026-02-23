# typed: false
# frozen_string_literal: true

module Auth
  module IoKeys
    SECURE_COOKIE_PREFIX = "__Secure-"

    module Cookies
      ACCESS_BASENAME = "jit_auth_access"
      REFRESH_BASENAME = "jit_auth_refresh"
      DEVICE_BASENAME = "jit_auth_device_id"
    end

    module Headers
      AUTHORIZATION = "Authorization"
      DEVICE_ID = "X-Device-Id"
      STRICT_DEVICE_CHECK = "X-STRICT-DEVICE-CHECK"
      TEST_CHECKPOINT = "X-TEST-CHECKPOINT"
      TEST_CURRENT_RESOURCE = "X-TEST-CURRENT-RESOURCE"
      TEST_CURRENT_USER = "X-TEST-CURRENT-USER"
      TEST_CURRENT_STAFF = "X-TEST-CURRENT-STAFF"
      TEST_CURRENT_VIEWER = "X-TEST-CURRENT-VIEWER"
      TEST_SESSION_PUBLIC_ID = "X-TEST-SESSION-PUBLIC-ID"
    end

    module Params
      RD = :rd
      RI = :ri
      RT = :rt
    end

    module Session
      DEFAULT_RD = :user_email_authentication_rd
      CHECKPOINT = :in_checkpoint
    end

    module Env
      AUTH_REFRESHED_FLAG = "jit_auth_refreshed"
    end
  end
end
