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

  test "can be created with preference and option" do
    option = org_preference_region_options(:jp)
    region = OrgPreferenceRegion.create!(preference: @preference, option: option)
    assert_not_nil region.id
    assert_equal @preference, region.preference
    assert_equal option, region.option
  end

  test "sets default option_id on create" do
    region = OrgPreferenceRegion.create!(preference: @preference)
    assert_equal "JP", region.option_id
  end
end
