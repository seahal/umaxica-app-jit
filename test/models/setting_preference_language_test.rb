# typed: false
# == Schema Information
#
# Table name: settings_preference_languages
# Database name: setting
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_languages_on_option_id      (option_id)
#  index_settings_preference_languages_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_languages_on_option_id      (option_id => settings_preference_language_options.id)
#  fk_settings_preference_languages_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceLanguageTest < ActiveSupport::TestCase
  fixtures :settings_preference_language_options

  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(owner_type: "User", owner_id: 1, user_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceLanguage, :<, SettingRecord
  end

  test "belongs to preference" do
    language = SettingPreferenceLanguage.new

    assert_not language.valid?
    assert_includes language.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = settings_preference_language_options(:ja)
    language = SettingPreferenceLanguage.create!(preference: @preference, option: option)

    assert_not_nil language.id
    assert_equal @preference, language.preference
    assert_equal option, language.option
  end

  test "sets default option_id on create" do
    language = SettingPreferenceLanguage.create!(preference: @preference)

    assert_equal SettingPreferenceLanguageOption::JA, language.option_id
  end

  test "validates uniqueness of preference_id" do
    option = settings_preference_language_options(:ja)
    SettingPreferenceLanguage.create!(preference: @preference, option: option)
    duplicate = SettingPreferenceLanguage.new(preference: @preference, option: option)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:preference_id], "はすでに存在します"
  end

  test "SettingPreferenceLanguageOption accepts numeric ids" do
    option = SettingPreferenceLanguageOption.create!(id: 99)

    assert_predicate option, :persisted?
    language = SettingPreferenceLanguage.create!(preference: @preference, option_id: 99)

    assert_equal option, language.option
  end
end
