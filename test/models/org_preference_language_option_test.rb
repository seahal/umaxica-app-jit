# == Schema Information
#
# Table name: org_preference_language_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_Org_Language")
    assert_not_nil option.id
  end

  test "has many org_preference_languages" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_Org_Language")
    preference = OrgPreference.create!
    language = OrgPreferenceLanguage.create!(preference: preference, option: option)
    assert_includes option.org_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_Org_Language")
    preference = OrgPreference.create!
    OrgPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
