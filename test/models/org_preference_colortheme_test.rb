# == Schema Information
#
# Table name: org_preference_colorthemes
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_org_preference_colorthemes_on_option_id      (option_id)
#  index_org_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceColorthemeTest < ActiveSupport::TestCase
  setup do
    @preference = OrgPreference.create!
  end

  test "belongs to preference" do
    colortheme = OrgPreferenceColortheme.new
    assert_not colortheme.valid?
    assert_includes colortheme.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = org_preference_colortheme_options(:light)
    colortheme = OrgPreferenceColortheme.create!(preference: @preference, option: option)
    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
    assert_equal option, colortheme.option
  end

  test "sets default option_id on create" do
    colortheme = OrgPreferenceColortheme.create!(preference: @preference)
    assert_equal "system", colortheme.option_id
  end
end
