# == Schema Information
#
# Table name: app_preference_timezone_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceTimezoneOption.create!
    assert_not_nil option.id
  end

  test "has many app_preference_timezones" do
    option = AppPreferenceTimezoneOption.create!
    preference = AppPreference.create!
    timezone = AppPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.app_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceTimezoneOption.create!
    preference = AppPreference.create!
    AppPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
