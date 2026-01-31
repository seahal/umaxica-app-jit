# == Schema Information
#
# Table name: app_preference_language_options
# Database name: preference
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  app_preference_language_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceLanguageOption.create!(id: "TEST_APP_LANGUAGE")
    assert_not_nil option.id
  end

  test "has many app_preference_languages" do
    option = AppPreferenceLanguageOption.create!(id: "TEST_APP_LANGUAGE")
    preference = AppPreference.create!
    language = AppPreferenceLanguage.create!(preference: preference, option: option)
    assert_includes option.app_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceLanguageOption.create!(id: "TEST_APP_LANGUAGE")
    preference = AppPreference.create!
    AppPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = AppPreferenceLanguageOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = AppPreferenceLanguageOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
