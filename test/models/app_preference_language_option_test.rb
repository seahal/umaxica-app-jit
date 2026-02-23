# typed: false
# == Schema Information
#
# Table name: app_preference_language_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceLanguageOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NEYO)
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
end
