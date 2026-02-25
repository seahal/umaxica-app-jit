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
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NEYO)
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
end
