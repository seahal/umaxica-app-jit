# == Schema Information
#
# Table name: org_preference_timezone_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_timezone_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_ORG_TIMEZONE")
    assert_not_nil option.id
  end

  test "has many org_preference_timezones" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_ORG_TIMEZONE")
    preference = OrgPreference.create!
    timezone = OrgPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.org_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceTimezoneOption.create!(id: "TEST_ORG_TIMEZONE")
    preference = OrgPreference.create!
    OrgPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = OrgPreferenceTimezoneOption.new(id: "invalid id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = OrgPreferenceTimezoneOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "downcases id before validation" do
    option = OrgPreferenceTimezoneOption.new(id: "ASIA/TOKYO")
    option.valid?
    assert_equal "asia/tokyo", option.id
  end
end
