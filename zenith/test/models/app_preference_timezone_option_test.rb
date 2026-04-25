# typed: false
# == Schema Information
#
# Table name: app_preference_timezone_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = AppPreferenceTimezoneOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many app_preference_timezones" do
    option = AppPreferenceTimezoneOption.create!(id: 99)
    preference = AppPreference.create!
    timezone = AppPreferenceTimezone.create!(preference: preference, option: option)

    assert_includes option.app_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceTimezoneOption.create!(id: 99)
    preference = AppPreference.create!
    AppPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "returns Etc/UTC for ETC_UTC id" do
    option = AppPreferenceTimezoneOption.new(id: AppPreferenceTimezoneOption::ETC_UTC)

    assert_equal "Etc/UTC", option.name
  end

  test "returns Asia/Tokyo for ASIA_TOKYO id" do
    option = AppPreferenceTimezoneOption.new(id: AppPreferenceTimezoneOption::ASIA_TOKYO)

    assert_equal "Asia/Tokyo", option.name
  end

  test "returns nil for NOTHING id" do
    option = AppPreferenceTimezoneOption.new(id: AppPreferenceTimezoneOption::NOTHING)

    assert_nil option.name
  end

  test "returns nil for unknown id" do
    option = AppPreferenceTimezoneOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2], AppPreferenceTimezoneOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    AppPreferenceTimezoneOption.where(id: AppPreferenceTimezoneOption::DEFAULTS).destroy_all

    AppPreferenceTimezoneOption.ensure_defaults!

    assert AppPreferenceTimezoneOption.exists?(id: AppPreferenceTimezoneOption::ETC_UTC)
    assert AppPreferenceTimezoneOption.exists?(id: AppPreferenceTimezoneOption::ASIA_TOKYO)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    AppPreferenceTimezoneOption.ensure_defaults!
    initial_count = AppPreferenceTimezoneOption.count

    AppPreferenceTimezoneOption.ensure_defaults!

    assert_equal initial_count, AppPreferenceTimezoneOption.count
  end
end
