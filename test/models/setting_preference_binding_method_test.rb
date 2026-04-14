# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_binding_methods
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceBindingMethodTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceBindingMethod::NOTHING
    assert_equal 1, SettingPreferenceBindingMethod::DBSC
    assert_equal 2, SettingPreferenceBindingMethod::LEGACY
  end

  test "defaults include all fixed ids" do
    assert_includes SettingPreferenceBindingMethod::DEFAULTS, SettingPreferenceBindingMethod::NOTHING
    assert_includes SettingPreferenceBindingMethod::DEFAULTS, SettingPreferenceBindingMethod::DBSC
    assert_includes SettingPreferenceBindingMethod::DEFAULTS, SettingPreferenceBindingMethod::LEGACY
  end

  test "can load nothing binding method from db" do
    method = SettingPreferenceBindingMethod.find(SettingPreferenceBindingMethod::NOTHING)

    assert_equal 0, method.id
  end

  test "has_many setting_preferences association is defined" do
    reflection = SettingPreferenceBindingMethod.reflect_on_association(:setting_preferences)

    assert_not_nil reflection
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceBindingMethod.where(id: SettingPreferenceBindingMethod::NOTHING).destroy_all

    assert_difference("SettingPreferenceBindingMethod.count") do
      SettingPreferenceBindingMethod.ensure_defaults!
    end
  end

  test "ensure_defaults! skips when all defaults exist" do
    SettingPreferenceBindingMethod.ensure_defaults!

    assert_no_difference("SettingPreferenceBindingMethod.count") do
      SettingPreferenceBindingMethod.ensure_defaults!
    end
  end
end
