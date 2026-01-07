# == Schema Information
#
# Table name: org_preference_languages
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_org_preference_languages_on_option_id      (option_id)
#  index_org_preference_languages_on_preference_id  (preference_id)
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

  test "can be created with preference" do
    language = OrgPreferenceLanguage.create!(preference: @preference)
    assert_not_nil language.id
    assert_equal @preference, language.preference
  end

  test "can be created with option" do
    option = OrgPreferenceLanguageOption.create!
    language = OrgPreferenceLanguage.create!(preference: @preference, option: option)
    assert_equal option, language.option
  end

  test "can be created without option" do
    language = OrgPreferenceLanguage.create!(preference: @preference)
    assert_nil language.option
  end
end
