# == Schema Information
#
# Table name: org_preference_timezone_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_Org_Timezone")
    assert_not_nil option.id
  end

  test "has many org_preference_timezones" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_Org_Timezone")
    preference = OrgPreference.create!
    timezone = OrgPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.org_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_Org_Timezone")
    preference = OrgPreference.create!
    OrgPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
