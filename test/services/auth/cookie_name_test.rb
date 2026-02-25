# typed: false
# frozen_string_literal: true

require "test_helper"

module Auth
  class CookieNameTest < ActiveSupport::TestCase
    test "returns non production cookie names without secure prefix" do
      assert_equal "jit_auth_access", Auth::CookieName.access(production: false)
      assert_equal "jit_auth_refresh", Auth::CookieName.refresh(production: false)
      assert_equal "jit_auth_device_id", Auth::CookieName.device(production: false)
    end

    test "returns production cookie names with secure prefix" do
      assert_equal "__Secure-jit_auth_access", Auth::CookieName.access(production: true)
      assert_equal "__Secure-jit_auth_refresh", Auth::CookieName.refresh(production: true)
      assert_equal "__Secure-jit_auth_device_id", Auth::CookieName.device(production: true)
    end

    test "derives device cookie key from refresh cookie key" do
      refresh = "__Secure-jit_auth_refresh"

      assert_equal "__Secure-jit_auth_device_id", Auth::CookieName.device(refresh_cookie_key: refresh)
    end
  end
end
