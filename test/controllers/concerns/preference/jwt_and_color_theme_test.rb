# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceColorThemeTest < ActiveSupport::TestCase
  test "COLORTHEME_SHORT_MAP contains correct mappings" do
    assert_equal "li", Preference::Base::COLORTHEME_SHORT_MAP["light"]
    assert_equal "dr", Preference::Base::COLORTHEME_SHORT_MAP["dark"]
    assert_equal "sy", Preference::Base::COLORTHEME_SHORT_MAP["system"]
  end

  test "COLORTHEME_OPTION_MAP contains correct mappings" do
    assert_equal "light", Preference::Base::COLORTHEME_OPTION_MAP["li"]
    assert_equal "dark", Preference::Base::COLORTHEME_OPTION_MAP["dr"]
    assert_equal "system", Preference::Base::COLORTHEME_OPTION_MAP["sy"]
  end
end

class PreferenceOptionMappingTest < ActiveSupport::TestCase
  test "ACCESS_TOKEN_TTL is 7 days" do
    assert_equal 7.days, Preference::Base::ACCESS_TOKEN_TTL
  end

  test "REFRESH_TOKEN_TTL is 400 days" do
    assert_equal 400.days, Preference::Base::REFRESH_TOKEN_TTL
  end

  test "THEME_COOKIE_KEY is correct" do
    assert_equal "jit_ct", Preference::Base::THEME_COOKIE_KEY
  end

  test "LANGUAGE_COOKIE_KEY is correct" do
    assert_equal "jit_lx", Preference::Base::LANGUAGE_COOKIE_KEY
  end

  test "TIMEZONE_COOKIE_KEY is correct" do
    assert_equal "jit_tz", Preference::Base::TIMEZONE_COOKIE_KEY
  end
end
