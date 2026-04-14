# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: settings_preference_language_options
# Database name: setting
#
#  id :bigint           not null, primary key
#
require "test_helper"

class SettingPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, SettingPreferenceLanguageOption::NOTHING
    assert_equal 1, SettingPreferenceLanguageOption::JA
    assert_equal 2, SettingPreferenceLanguageOption::EN
  end

  test "can load ja option from db" do
    option = SettingPreferenceLanguageOption.find(SettingPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "can load en option from db" do
    option = SettingPreferenceLanguageOption.find(SettingPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "ensure_defaults! creates missing default records" do
    SettingPreferenceLanguageOption.where(id: SettingPreferenceLanguageOption::JA).destroy_all

    assert_difference("SettingPreferenceLanguageOption.count") do
      SettingPreferenceLanguageOption.ensure_defaults!
    end
  end
end
