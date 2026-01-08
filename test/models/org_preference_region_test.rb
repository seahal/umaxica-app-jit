# == Schema Information
#
# Table name: org_preference_regions
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_org_preference_regions_on_option_id      (option_id)
#  index_org_preference_regions_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceRegionTest < ActiveSupport::TestCase
  setup do
    @preference = OrgPreference.create!
  end

  test "belongs to preference" do
    region = OrgPreferenceRegion.new
    assert_not region.valid?
    assert_includes region.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    region = OrgPreferenceRegion.create!(preference: @preference)
    assert_not_nil region.id
    assert_equal @preference, region.preference
  end

  test "can be created with option" do
    option = OrgPreferenceRegionOption.create!(id: "TEST_ORG_REGION")
    region = OrgPreferenceRegion.create!(preference: @preference, option: option)
    assert_equal option, region.option
  end

  test "can be created without option" do
    region = OrgPreferenceRegion.create!(preference: @preference)
    assert_nil region.option
  end
end
