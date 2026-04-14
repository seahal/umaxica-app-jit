# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class ConstantsTest < ActiveSupport::TestCase
    test "PREFERENCE_KEYS contains expected keys" do
      assert_equal %w(lx ri tz ct), Constants::PREFERENCE_KEYS
      assert_predicate Constants::PREFERENCE_KEYS, :frozen?
    end

    test "DEFAULT_PREFERENCES has correct defaults" do
      defaults = Constants::DEFAULT_PREFERENCES

      assert_equal "ja", defaults["lx"]
      assert_equal "jp", defaults["ri"]
      assert_equal "jst", defaults["tz"]
      assert_equal "sy", defaults["ct"]
      assert_predicate Constants::DEFAULT_PREFERENCES, :frozen?
    end

    test "PREFERENCE_KEYS and DEFAULT_PREFERENCES have matching keys" do
      assert_equal Constants::PREFERENCE_KEYS.sort, Constants::DEFAULT_PREFERENCES.keys.sort
    end
  end
end
