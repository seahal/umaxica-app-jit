# typed: false
# == Schema Information
#
# Table name: org_preference_timezone_options
# Database name: operator
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  setup do
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NOTHING)
  end

  test "ensure_defaults! creates default timezone options" do
    OrgPreferenceTimezoneOption.where(id: OrgPreferenceTimezoneOption::DEFAULTS).delete_all

    assert_empty OrgPreferenceTimezoneOption.where(id: OrgPreferenceTimezoneOption::DEFAULTS)

    OrgPreferenceTimezoneOption.ensure_defaults!

    assert_equal OrgPreferenceTimezoneOption::DEFAULTS.sort, OrgPreferenceTimezoneOption.where(id: OrgPreferenceTimezoneOption::DEFAULTS).pluck(:id).sort
  end

  test "can be created" do
    option = OrgPreferenceTimezoneOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many org_preference_timezones" do
    option = OrgPreferenceTimezoneOption.create!(id: 99)
    preference = OrgPreference.create!
    timezone = OrgPreferenceTimezone.create!(preference: preference, option: option)

    assert_includes option.org_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceTimezoneOption.create!(id: 99)
    preference = OrgPreference.create!
    OrgPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "returns Etc/UTC for ETC_UTC id" do
    option = OrgPreferenceTimezoneOption.new(id: OrgPreferenceTimezoneOption::ETC_UTC)

    assert_equal "Etc/UTC", option.name
  end

  test "returns Asia/Tokyo for ASIA_TOKYO id" do
    option = OrgPreferenceTimezoneOption.new(id: OrgPreferenceTimezoneOption::ASIA_TOKYO)

    assert_equal "Asia/Tokyo", option.name
  end

  test "returns nil for unknown id" do
    option = OrgPreferenceTimezoneOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2], OrgPreferenceTimezoneOption::DEFAULTS
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    OrgPreferenceTimezoneOption.ensure_defaults!
    initial_count = OrgPreferenceTimezoneOption.count

    OrgPreferenceTimezoneOption.ensure_defaults!

    assert_equal initial_count, OrgPreferenceTimezoneOption.count
  end
end
