# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_region_options
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceRegionOption::NOTHING
    assert_equal 1, SettingPreferenceRegionOption::US
    assert_equal 2, SettingPreferenceRegionOption::JP
  end

  test "can load jp option from db" do
    option = SettingPreferenceRegionOption.find(SettingPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceRegionOption.where(id: SettingPreferenceRegionOption::JP).destroy_all

    assert_difference("SettingPreferenceRegionOption.count") do
      SettingPreferenceRegionOption.ensure_defaults!
    end
  end

  test "name returns US for US id" do
    option = SettingPreferenceRegionOption.find(SettingPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns nil for NOTHING id" do
    option = SettingPreferenceRegionOption.find(SettingPreferenceRegionOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = SettingPreferenceRegionOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2], SettingPreferenceRegionOption::DEFAULTS
  end
end
