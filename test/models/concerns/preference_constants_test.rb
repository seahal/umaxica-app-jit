# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceConstantsTest < ActiveSupport::TestCase
  test "preference_constants is defined" do
    assert defined?(PreferenceConstants)
  end

  test "preference_constants equals preference constants" do
    assert_equal Preference::Constants, PreferenceConstants
  end
end
