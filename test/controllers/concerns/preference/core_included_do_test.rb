# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceCoreIncludedDoTest < ActiveSupport::TestCase
  test "ensure_preferences_record method exists (private)" do
    skip "Preference::Core requires Preference::Base abstract methods"
  end

  test "COOKIE_EXPIRY constant is defined" do
    assert_equal 400.days, Preference::Core::COOKIE_EXPIRY
  end

  test "set_region_preferences_edit method exists" do
    assert_includes Preference::Core.instance_methods(false), :set_region_preferences_edit
  end

  test "set_region_preferences_update method exists" do
    assert_includes Preference::Core.instance_methods(false), :set_region_preferences_update
  end
end
