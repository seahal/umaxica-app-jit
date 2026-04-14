# typed: false
# == Schema Information
#
# Table name: settings_preference_activities
# Database name: setting
#
#  id            :bigint           not null, primary key
#  action        :string           not null
#  actor_type    :string
#  metadata      :jsonb
#  created_at    :datetime         not null
#  actor_id      :bigint
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_activities_on_actor          (actor_type,actor_id)
#  index_settings_preference_activities_on_created_at     (created_at)
#  index_settings_preference_activities_on_preference_id  (preference_id)
#
# Foreign Keys
#
#  fk_settings_preference_activities_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceActivityTest < ActiveSupport::TestCase
  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(owner_type: "User", owner_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceActivity, :<, SettingRecord
  end

  test "uses custom table name" do
    assert_equal "settings_preference_activities", SettingPreferenceActivity.table_name
  end

  test "does not record timestamps" do
    assert_not SettingPreferenceActivity.record_timestamps
  end

  test "belongs to setting_preference" do
    reflection = SettingPreferenceActivity.reflect_on_association(:setting_preference)

    assert_not_nil reflection
    assert_equal :belongs_to, reflection.macro
    assert_equal "SettingPreference", reflection.class_name
    assert_equal :preference_id, reflection.foreign_key.to_sym
  end

  test "requires action" do
    activity = SettingPreferenceActivity.new(setting_preference: @preference, action: nil)

    assert_not activity.valid?
    assert_includes activity.errors[:action], "を入力してください"
  end

  test "rejects blank string action" do
    activity = SettingPreferenceActivity.new(setting_preference: @preference, action: "")

    assert_not activity.valid?
  end

  test "can be created with valid attributes" do
    activity = SettingPreferenceActivity.create!(
      setting_preference: @preference,
      action: "page_view",
      created_at: Time.current,
    )

    assert_not_nil activity.id
    assert_equal "page_view", activity.action
    assert_equal @preference, activity.setting_preference
  end

  test "requires setting_preference" do
    activity = SettingPreferenceActivity.new(action: "page_view")

    assert_not activity.valid?
  end

  test "requires created_at" do
    activity = SettingPreferenceActivity.new(
      setting_preference: @preference,
      action: "page_view",
      created_at: nil,
    )

    assert_not activity.valid?
    assert_includes activity.errors[:created_at], "を入力してください"
  end

  test "validates created_at must be present" do
    activity = SettingPreferenceActivity.new(
      setting_preference: @preference,
      action: "page_view",
      created_at: "",
    )

    assert_not activity.valid?
    assert_not_empty activity.errors[:created_at]
  end
end
