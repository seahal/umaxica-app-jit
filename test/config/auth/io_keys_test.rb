# frozen_string_literal: true

require "test_helper"

class AuthIoKeysTest < ActiveSupport::TestCase
  test "io keys modules are loadable" do
    assert defined?(Auth::IoKeys)
    assert defined?(Preference::IoKeys)
  end

  test "auth io key values stay stable" do
    assert_equal "__Secure-", Auth::IoKeys::SECURE_COOKIE_PREFIX
    assert_equal "jit_auth_access", Auth::IoKeys::Cookies::ACCESS_BASENAME
    assert_equal "jit_auth_refresh", Auth::IoKeys::Cookies::REFRESH_BASENAME
    assert_equal "jit_auth_device_id", Auth::IoKeys::Cookies::DEVICE_BASENAME
    assert_equal "Authorization", Auth::IoKeys::Headers::AUTHORIZATION
    assert_equal "X-Device-Id", Auth::IoKeys::Headers::DEVICE_ID
    assert_equal :rd, Auth::IoKeys::Params::RD
    assert_equal :user_email_authentication_rd, Auth::IoKeys::Session::DEFAULT_RD
  end

  test "preference io key values stay stable" do
    assert_equal "__Secure-", Preference::IoKeys::SECURE_COOKIE_PREFIX
    assert_equal "jit_ct", Preference::IoKeys::Cookies::THEME
    assert_equal "ct", Preference::IoKeys::Cookies::LEGACY_THEME
    assert_equal "jit_lx", Preference::IoKeys::Cookies::LANGUAGE
    assert_equal "jit_tz", Preference::IoKeys::Cookies::TIMEZONE
    assert_equal "jit_preference_access", Preference::IoKeys::Cookies::ACCESS_BASENAME
    assert_equal "jit_preference_refresh", Preference::IoKeys::Cookies::REFRESH_BASENAME
    assert_equal "jit_preference_device_id", Preference::IoKeys::Cookies::DEVICE_BASENAME
    assert_equal "X-Device-Id", Preference::IoKeys::Headers::DEVICE_ID
    assert_equal :refresh_token, Preference::IoKeys::Params::REFRESH_TOKEN
  end
end
