# frozen_string_literal: true

require "test_helper"

module Preference
  class CookieNameTest < ActiveSupport::TestCase
    test "returns non production cookie names without secure prefix" do
      assert_equal "jit_preference_access", Preference::CookieName.access(production: false)
      assert_equal "jit_preference_refresh", Preference::CookieName.refresh(production: false)
      assert_equal "jit_preference_device_id", Preference::CookieName.device(production: false)
    end

    test "returns production cookie names with secure prefix" do
      assert_equal "__Secure-jit_preference_access", Preference::CookieName.access(production: true)
      assert_equal "__Secure-jit_preference_refresh", Preference::CookieName.refresh(production: true)
      assert_equal "__Secure-jit_preference_device_id", Preference::CookieName.device(production: true)
    end

    test "derives device cookie key from refresh cookie key" do
      refresh = "__Secure-jit_preference_refresh"
      assert_equal "__Secure-jit_preference_device_id", Preference::CookieName.device(refresh_cookie_key: refresh)
    end
  end
end
