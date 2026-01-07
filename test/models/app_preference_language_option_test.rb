# == Schema Information
#
# Table name: app_preference_language_options
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceLanguageOption.create!
    assert_not_nil option.id
  end

  test "has many app_preference_languages" do
    option = AppPreferenceLanguageOption.create!
    preference = AppPreference.create!
    language = AppPreferenceLanguage.create!(preference: preference, option: option)
    assert_includes option.app_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceLanguageOption.create!
    preference = AppPreference.create!
    AppPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
