# typed: false
# == Schema Information
#
# Table name: settings_preference_colorthemes
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
#  index_settings_preference_colorthemes_on_option_id      (option_id)
#  index_settings_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_colorthemes_on_option_id      (option_id => settings_preference_colortheme_options.id)
#  fk_settings_preference_colorthemes_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceColorthemeTest < ActiveSupport::TestCase
  fixtures :settings_preference_colortheme_options

  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(user_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceColortheme, :<, SettingRecord
  end

  test "belongs to preference" do
    colortheme = SettingPreferenceColortheme.new

    assert_not colortheme.valid?
    assert_not_empty colortheme.errors[:preference]
  end

  test "can be created with preference and option" do
    option = settings_preference_colortheme_options(:light)
    colortheme = SettingPreferenceColortheme.create!(preference: @preference, option: option)

    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
    assert_equal option, colortheme.option
  end

  test "sets default option_id on create" do
    colortheme = SettingPreferenceColortheme.create!(preference: @preference)

    assert_equal SettingPreferenceColorthemeOption::SYSTEM, colortheme.option_id
  end

  test "validates uniqueness of preference_id" do
    option = settings_preference_colortheme_options(:light)
    SettingPreferenceColortheme.create!(preference: @preference, option: option)
    duplicate = SettingPreferenceColortheme.new(preference: @preference, option: option)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:preference_id]
  end

  test "before_validation callback sets default option_id when nil" do
    colortheme = SettingPreferenceColortheme.new(preference: @preference)
    colortheme.option_id = nil

    assert_predicate colortheme, :valid?
    assert_equal SettingPreferenceColorthemeOption::SYSTEM, colortheme.option_id
  end
end
