# == Schema Information
#
# Table name: com_preference_timezone_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_Com_Timezone")
    assert_not_nil option.id
  end

  test "has many com_preference_timezones" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_Com_Timezone")
    preference = ComPreference.create!
    timezone = ComPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.com_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_Com_Timezone")
    preference = ComPreference.create!
    ComPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
