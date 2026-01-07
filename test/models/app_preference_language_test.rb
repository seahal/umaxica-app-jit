# == Schema Information
#
# Table name: app_preference_languages
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_app_preference_languages_on_option_id      (option_id)
#  index_app_preference_languages_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceLanguageTest < ActiveSupport::TestCase
  setup do
    @preference = AppPreference.create!
  end

  test "belongs to preference" do
    language = AppPreferenceLanguage.new
    assert_not language.valid?
    assert_includes language.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    language = AppPreferenceLanguage.create!(preference: @preference)
    assert_not_nil language.id
    assert_equal @preference, language.preference
  end

  test "can be created with option" do
    option = AppPreferenceLanguageOption.create!(id: "TEST_App_Language")
    language = AppPreferenceLanguage.create!(preference: @preference, option: option)
    assert_equal option, language.option
  end

  test "can be created without option" do
    language = AppPreferenceLanguage.create!(preference: @preference)
    assert_nil language.option
  end

  test "validates uniqueness of preference" do
    AppPreferenceLanguage.create!(preference: @preference)
    duplicate_language = AppPreferenceLanguage.new(preference: @preference)
    assert_not duplicate_language.valid?
    assert_includes duplicate_language.errors[:preference_id], "はすでに存在します"
  end
end
