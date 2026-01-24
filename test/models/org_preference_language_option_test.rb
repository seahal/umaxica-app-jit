# == Schema Information
#
# Table name: org_preference_language_options
# Database name: preference
#
#  id         :string           not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  org_preference_language_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_ORG_LANGUAGE")
    assert_not_nil option.id
  end

  test "has many org_preference_languages" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_ORG_LANGUAGE")
    preference = OrgPreference.create!
    language = OrgPreferenceLanguage.create!(preference: preference, option: option)
    assert_includes option.org_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceLanguageOption.create!(id: "TEST_ORG_LANGUAGE")
    preference = OrgPreference.create!
    OrgPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = OrgPreferenceLanguageOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = OrgPreferenceLanguageOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
