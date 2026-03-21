# typed: false
# == Schema Information
#
# Table name: org_preference_language_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceLanguageOptionTest < ActiveSupport::TestCase
  setup do
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = OrgPreferenceLanguageOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many org_preference_languages" do
    option = OrgPreferenceLanguageOption.create!(id: 99)
    preference = OrgPreference.create!
    language = OrgPreferenceLanguage.create!(preference: preference, option: option)

    assert_includes option.org_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceLanguageOption.create!(id: 99)
    preference = OrgPreference.create!
    OrgPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns ja for JA id" do
    option = OrgPreferenceLanguageOption.find_or_create_by!(id: OrgPreferenceLanguageOption::JA)
    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = OrgPreferenceLanguageOption.find_or_create_by!(id: OrgPreferenceLanguageOption::EN)
    assert_equal "en", option.name
  end

  test "name returns nil for unknown id" do
    option = OrgPreferenceLanguageOption.find_or_create_by!(id: 999)
    assert_nil option.name
  end
end
