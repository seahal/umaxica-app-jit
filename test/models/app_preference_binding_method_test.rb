# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_binding_methods
# Database name: preference
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppPreferenceBindingMethodTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, AppPreferenceBindingMethod::NOTHING
    assert_equal 1, AppPreferenceBindingMethod::DBSC
    assert_equal 2, AppPreferenceBindingMethod::LEGACY
  end

  test "defaults includes NOTHING, DBSC, and LEGACY" do
    assert_includes AppPreferenceBindingMethod::DEFAULTS, AppPreferenceBindingMethod::NOTHING
    assert_includes AppPreferenceBindingMethod::DEFAULTS, AppPreferenceBindingMethod::DBSC
    assert_includes AppPreferenceBindingMethod::DEFAULTS, AppPreferenceBindingMethod::LEGACY
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppPreferenceBindingMethod.count" do
      AppPreferenceBindingMethod.ensure_defaults!
    end
  end
end
