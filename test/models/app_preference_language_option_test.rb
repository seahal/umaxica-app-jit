# typed: false
# == Schema Information
#
# Table name: app_preference_language_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceLanguageOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NOTHING)
  end

  test "has correct constants" do
    assert_equal 0, AppPreferenceLanguageOption::NOTHING
    assert_equal 1, AppPreferenceLanguageOption::JA
    assert_equal 2, AppPreferenceLanguageOption::EN
  end

  test "defaults includes NOTHING" do
    assert_includes AppPreferenceLanguageOption::DEFAULTS, AppPreferenceLanguageOption::NOTHING
  end

  test "can be created" do
    option = AppPreferenceLanguageOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many app_preference_languages" do
    option = AppPreferenceLanguageOption.create!(id: 99)
    preference = AppPreference.create!
    language = AppPreferenceLanguage.create!(preference: preference, option: option)

    assert_includes option.app_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceLanguageOption.create!(id: 99)
    preference = AppPreference.create!
    AppPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns ja for JA id" do
    option = AppPreferenceLanguageOption.find_or_create_by!(id: AppPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = AppPreferenceLanguageOption.find_or_create_by!(id: AppPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for unknown id" do
    option = AppPreferenceLanguageOption.find_or_create_by!(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2], AppPreferenceLanguageOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    AppPreferenceLanguageOption.where(id: AppPreferenceLanguageOption::DEFAULTS).destroy_all

    AppPreferenceLanguageOption.ensure_defaults!

    assert AppPreferenceLanguageOption.exists?(id: AppPreferenceLanguageOption::NOTHING)
    assert AppPreferenceLanguageOption.exists?(id: AppPreferenceLanguageOption::JA)
    assert AppPreferenceLanguageOption.exists?(id: AppPreferenceLanguageOption::EN)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    AppPreferenceLanguageOption.ensure_defaults!
    initial_count = AppPreferenceLanguageOption.count

    AppPreferenceLanguageOption.ensure_defaults!

    assert_equal initial_count, AppPreferenceLanguageOption.count
  end
end
