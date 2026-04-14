# typed: false
# == Schema Information
#
# Table name: settings_preference_timezones
# Database name: setting
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_timezones_on_option_id      (option_id)
#  index_settings_preference_timezones_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_timezones_on_option_id      (option_id => settings_preference_timezone_options.id)
#  fk_settings_preference_timezones_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceTimezoneTest < ActiveSupport::TestCase
  fixtures :settings_preference_timezone_options

  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(owner_type: "User", owner_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceTimezone, :<, SettingRecord
  end

  test "belongs to preference" do
    timezone = SettingPreferenceTimezone.new

    assert_not timezone.valid?
    assert_includes timezone.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = settings_preference_timezone_options(:asia_tokyo)
    timezone = SettingPreferenceTimezone.create!(preference: @preference, option: option)

    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
    assert_equal option, timezone.option
  end

  test "sets default option_id on create" do
    timezone = SettingPreferenceTimezone.create!(preference: @preference)

    assert_equal SettingPreferenceTimezoneOption::ASIA_TOKYO, timezone.option_id
  end

  test "validates uniqueness of preference_id" do
    option = settings_preference_timezone_options(:asia_tokyo)
    SettingPreferenceTimezone.create!(preference: @preference, option: option)
    duplicate = SettingPreferenceTimezone.new(preference: @preference, option: option)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:preference_id], "はすでに存在します"
  end

  test "SettingPreferenceTimezoneOption accepts numeric ids" do
    option = SettingPreferenceTimezoneOption.create!(id: 99)

    assert_predicate option, :persisted?
    timezone = SettingPreferenceTimezone.create!(preference: @preference, option_id: 99)

    assert_equal option, timezone.option
  end
end
