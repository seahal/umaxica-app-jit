# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceWebThemeActionsIncludedDoTest < ActiveSupport::TestCase
  test "show method exists" do
    assert Preference::WebThemeActions.method_defined?(:show)
  end

  test "update method exists" do
    assert Preference::WebThemeActions.method_defined?(:update)
  end

  test "activate_web_theme_actions class method exists" do
    assert_includes Preference::WebThemeActions::ClassMethods.instance_methods(false), :activate_web_theme_actions
  end
end
