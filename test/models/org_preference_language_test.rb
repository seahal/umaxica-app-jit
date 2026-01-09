# == Schema Information
#
# Table name: org_preference_languages
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_org_preference_languages_on_option_id      (option_id)
#  index_org_preference_languages_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceLanguageTest < ActiveSupport::TestCase
  setup do
    @preference = OrgPreference.create!
  end

  test "belongs to preference" do
    language = OrgPreferenceLanguage.new
    assert_not language.valid?
    assert_includes language.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = org_preference_language_options(:ja)
    language = OrgPreferenceLanguage.create!(preference: @preference, option: option)
    assert_not_nil language.id
    assert_equal @preference, language.preference
    assert_equal option, language.option
  end

  test "sets default option_id on create" do
    language = OrgPreferenceLanguage.create!(preference: @preference)
    assert_equal "JA", language.option_id
  end
end
