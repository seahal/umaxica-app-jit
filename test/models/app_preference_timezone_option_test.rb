# == Schema Information
#
# Table name: app_preference_timezone_options
# Database name: preference
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  app_preference_timezone_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceTimezoneOption.create!(id: "TEST_APP_TIMEZONE")
    assert_not_nil option.id
  end

  test "has many app_preference_timezones" do
    option = AppPreferenceTimezoneOption.create!(id: "TEST_APP_TIMEZONE")
    preference = AppPreference.create!
    timezone = AppPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.app_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceTimezoneOption.create!(id: "TEST_APP_TIMEZONE")
    preference = AppPreference.create!
    AppPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = AppPreferenceTimezoneOption.new(id: "invalid id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = AppPreferenceTimezoneOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
