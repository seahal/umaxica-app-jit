# == Schema Information
#
# Table name: org_preference_colorthemes
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_org_preference_colorthemes_on_option_id      (option_id)
#  index_org_preference_colorthemes_on_preference_id  (preference_id)
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

  test "can be created with preference" do
    colortheme = OrgPreferenceColortheme.create!(preference: @preference)
    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
  end

  test "can be created with option" do
    option = OrgPreferenceColorthemeOption.create!
    colortheme = OrgPreferenceColortheme.create!(preference: @preference, option: option)
    assert_equal option, colortheme.option
  end

  test "can be created without option" do
    colortheme = OrgPreferenceColortheme.create!(preference: @preference)
    assert_nil colortheme.option
  end
end
