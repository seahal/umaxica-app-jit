# == Schema Information
#
# Table name: org_preference_region_options
# Database name: preference
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  org_preference_region_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceRegionOption.create!(id: "TEST_ORG_REGION")
    assert_not_nil option.id
  end

  test "has many org_preference_regions" do
    option = OrgPreferenceRegionOption.create!(id: "TEST_ORG_REGION")
    preference = OrgPreference.create!
    region = OrgPreferenceRegion.create!(preference: preference, option: option)
    assert_includes option.org_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceRegionOption.create!(id: "TEST_ORG_REGION")
    preference = OrgPreference.create!
    OrgPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = OrgPreferenceRegionOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = OrgPreferenceRegionOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
