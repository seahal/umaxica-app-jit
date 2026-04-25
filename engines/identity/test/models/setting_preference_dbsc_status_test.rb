# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_dbsc_statuses
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceDbscStatusTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceDbscStatus::NOTHING
    assert_equal 1, SettingPreferenceDbscStatus::ACTIVE
    assert_equal 2, SettingPreferenceDbscStatus::PENDING
    assert_equal 3, SettingPreferenceDbscStatus::FAILED
    assert_equal 4, SettingPreferenceDbscStatus::REVOKE
  end

  test "defaults include all fixed ids" do
    assert_includes SettingPreferenceDbscStatus::DEFAULTS, SettingPreferenceDbscStatus::NOTHING
    assert_includes SettingPreferenceDbscStatus::DEFAULTS, SettingPreferenceDbscStatus::ACTIVE
    assert_includes SettingPreferenceDbscStatus::DEFAULTS, SettingPreferenceDbscStatus::PENDING
    assert_includes SettingPreferenceDbscStatus::DEFAULTS, SettingPreferenceDbscStatus::FAILED
    assert_includes SettingPreferenceDbscStatus::DEFAULTS, SettingPreferenceDbscStatus::REVOKE
  end

  test "can load nothing status from db" do
    status = SettingPreferenceDbscStatus.find(SettingPreferenceDbscStatus::NOTHING)

    assert_equal 0, status.id
  end

  test "has_many setting_preferences association is defined" do
    reflection = SettingPreferenceDbscStatus.reflect_on_association(:setting_preferences)

    assert_not_nil reflection
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceDbscStatus.where(id: SettingPreferenceDbscStatus::NOTHING).destroy_all

    assert_difference("SettingPreferenceDbscStatus.count") do
      SettingPreferenceDbscStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! skips when all defaults exist" do
    SettingPreferenceDbscStatus.ensure_defaults!

    assert_no_difference("SettingPreferenceDbscStatus.count") do
      SettingPreferenceDbscStatus.ensure_defaults!
    end
  end
end
