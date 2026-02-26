# typed: false
# == Schema Information
#
# Table name: com_preference_timezone_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  setup do
    ComPreferenceStatus.find_or_create_by!(id: ComPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = ComPreferenceTimezoneOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many com_preference_timezones" do
    option = ComPreferenceTimezoneOption.create!(id: 99)
    preference = ComPreference.create!
    timezone = ComPreferenceTimezone.create!(preference: preference, option: option)

    assert_includes option.com_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceTimezoneOption.create!(id: 99)
    preference = ComPreference.create!
    ComPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
