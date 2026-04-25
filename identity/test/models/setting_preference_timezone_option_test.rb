# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_timezone_options
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceTimezoneOption::NOTHING
    assert_equal 1, SettingPreferenceTimezoneOption::ETC_UTC
    assert_equal 2, SettingPreferenceTimezoneOption::ASIA_TOKYO
  end

  test "can load asia_tokyo option from db" do
    option = SettingPreferenceTimezoneOption.find(SettingPreferenceTimezoneOption::ASIA_TOKYO)

    assert_equal "Asia/Tokyo", option.name
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceTimezoneOption.where(id: SettingPreferenceTimezoneOption::ASIA_TOKYO).destroy_all

    assert_difference("SettingPreferenceTimezoneOption.count") do
      SettingPreferenceTimezoneOption.ensure_defaults!
    end
  end

  test "name returns Etc/UTC for ETC_UTC id" do
    option = SettingPreferenceTimezoneOption.find(SettingPreferenceTimezoneOption::ETC_UTC)

    assert_equal "Etc/UTC", option.name
  end

  test "name returns nil for NOTHING id" do
    option = SettingPreferenceTimezoneOption.find(SettingPreferenceTimezoneOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = SettingPreferenceTimezoneOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2], SettingPreferenceTimezoneOption::DEFAULTS
  end
end
