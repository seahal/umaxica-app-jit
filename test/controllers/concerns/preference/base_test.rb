# frozen_string_literal: true

require "test_helper"

module Preference
  class BaseTest < ActiveSupport::TestCase
    test "preference cookie key constants are stable" do
      assert_equal "jit_ct", Preference::Base::THEME_COOKIE_KEY
      assert_equal "ct", Preference::Base::LEGACY_THEME_COOKIE_KEY
      assert_equal "jit_lx", Preference::Base::LANGUAGE_COOKIE_KEY
      assert_equal "jit_tz", Preference::Base::TIMEZONE_COOKIE_KEY
    end
  end
end
