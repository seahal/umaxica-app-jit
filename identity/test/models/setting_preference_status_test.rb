# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_statuses
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceStatusTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceStatus::NOTHING
    assert_equal 1, SettingPreferenceStatus::DELETED
    assert_equal 2, SettingPreferenceStatus::LEGACY_NOTHING
  end

  test "defaults include all fixed ids" do
    assert_includes SettingPreferenceStatus::DEFAULTS, SettingPreferenceStatus::NOTHING
    assert_includes SettingPreferenceStatus::DEFAULTS, SettingPreferenceStatus::DELETED
    assert_includes SettingPreferenceStatus::DEFAULTS, SettingPreferenceStatus::LEGACY_NOTHING
  end

  test "can load nothing status from db" do
    status = SettingPreferenceStatus.find(SettingPreferenceStatus::NOTHING)

    assert_equal 0, status.id
  end

  test "has_many setting_preferences association is defined" do
    reflection = SettingPreferenceStatus.reflect_on_association(:setting_preferences)

    assert_not_nil reflection
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceStatus.where(id: SettingPreferenceStatus::NOTHING).destroy_all

    assert_difference("SettingPreferenceStatus.count") do
      SettingPreferenceStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! skips when all defaults exist" do
    SettingPreferenceStatus.ensure_defaults!

    assert_no_difference("SettingPreferenceStatus.count") do
      SettingPreferenceStatus.ensure_defaults!
    end
  end
end
