# typed: false
# == Schema Information
#
# Table name: com_preference_timezone_options
# Database name: commerce
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  setup do
    ComPreferenceStatus.find_or_create_by!(id: ComPreferenceStatus::NOTHING)
  end

  test "ensure_defaults! creates default timezone options" do
    ComPreferenceTimezoneOption.where(id: ComPreferenceTimezoneOption::DEFAULTS).delete_all

    assert_empty ComPreferenceTimezoneOption.where(id: ComPreferenceTimezoneOption::DEFAULTS)

    ComPreferenceTimezoneOption.ensure_defaults!

    assert_equal ComPreferenceTimezoneOption::DEFAULTS.sort, ComPreferenceTimezoneOption.where(id: ComPreferenceTimezoneOption::DEFAULTS).pluck(:id).sort
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

  test "returns Etc/UTC for ETC_UTC id" do
    option = ComPreferenceTimezoneOption.new(id: ComPreferenceTimezoneOption::ETC_UTC)

    assert_equal "Etc/UTC", option.name
  end

  test "returns Asia/Tokyo for ASIA_TOKYO id" do
    option = ComPreferenceTimezoneOption.new(id: ComPreferenceTimezoneOption::ASIA_TOKYO)

    assert_equal "Asia/Tokyo", option.name
  end

  test "returns nil for unknown id" do
    option = ComPreferenceTimezoneOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2], ComPreferenceTimezoneOption::DEFAULTS
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    ComPreferenceTimezoneOption.ensure_defaults!
    initial_count = ComPreferenceTimezoneOption.count

    ComPreferenceTimezoneOption.ensure_defaults!

    assert_equal initial_count, ComPreferenceTimezoneOption.count
  end
end
