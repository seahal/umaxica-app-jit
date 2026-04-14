# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_colortheme_options
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceColorthemeOption::NOTHING
    assert_equal 1, SettingPreferenceColorthemeOption::LIGHT
    assert_equal 2, SettingPreferenceColorthemeOption::DARK
    assert_equal 3, SettingPreferenceColorthemeOption::SYSTEM
  end

  test "can load system option from db" do
    option = SettingPreferenceColorthemeOption.find(SettingPreferenceColorthemeOption::SYSTEM)

    assert_equal "system", option.name
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceColorthemeOption.where(id: SettingPreferenceColorthemeOption::SYSTEM).destroy_all

    assert_difference("SettingPreferenceColorthemeOption.count") do
      SettingPreferenceColorthemeOption.ensure_defaults!
    end
  end

  test "name returns light for LIGHT id" do
    option = SettingPreferenceColorthemeOption.find(SettingPreferenceColorthemeOption::LIGHT)

    assert_equal "light", option.name
  end

  test "name returns dark for DARK id" do
    option = SettingPreferenceColorthemeOption.find(SettingPreferenceColorthemeOption::DARK)

    assert_equal "dark", option.name
  end

  test "name returns nil for NOTHING id" do
    option = SettingPreferenceColorthemeOption.find(SettingPreferenceColorthemeOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = SettingPreferenceColorthemeOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2, 3], SettingPreferenceColorthemeOption::DEFAULTS
  end
end
