# == Schema Information
#
# Table name: com_preference_language_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceLanguageOption.create!(id: "TEST_Com_Language")
    assert_not_nil option.id
  end

  test "has many com_preference_languages" do
    option = ComPreferenceLanguageOption.create!(id: "TEST_Com_Language")
    preference = ComPreference.create!
    language = ComPreferenceLanguage.create!(preference: preference, option: option)
    assert_includes option.com_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceLanguageOption.create!(id: "TEST_Com_Language")
    preference = ComPreference.create!
    ComPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
