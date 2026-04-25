# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class CookieNameTest < ActiveSupport::TestCase
    test "returns non production cookie names without secure prefix" do
      assert_equal "preference_access", Preference::CookieName.access(production: false)
      assert_equal "preference_refresh", Preference::CookieName.refresh(production: false)
      assert_equal "preference_device_id", Preference::CookieName.device(production: false)
    end

    test "returns production cookie names with secure prefix" do
      assert_equal "__Secure-preference_access", Preference::CookieName.access(production: true)
      assert_equal "__Secure-preference_refresh", Preference::CookieName.refresh(production: true)
      assert_equal "__Secure-preference_device_id", Preference::CookieName.device(production: true)
    end

    test "derives device cookie key from refresh cookie key" do
      refresh = "__Secure-preference_refresh"

      assert_equal "__Secure-preference_device_id",
                   Preference::CookieName.device(refresh_cookie_key: refresh)
    end

    test "returns non production dbsc cookie name" do
      assert_equal "preference_dbsc", Preference::CookieName.dbsc(production: false)
    end

    test "returns production dbsc cookie name with secure prefix" do
      assert_equal "__Secure-preference_dbsc", Preference::CookieName.dbsc(production: true)
    end
  end
end
