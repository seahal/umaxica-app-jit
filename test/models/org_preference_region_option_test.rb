# typed: false
# == Schema Information
#
# Table name: org_preference_region_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceRegionOptionTest < ActiveSupport::TestCase
  setup do
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NEYO)
  end

  test "can be created" do
    option = OrgPreferenceRegionOption.create!(id: 99)
    assert_not_nil option.id
  end

  test "has many org_preference_regions" do
    option = OrgPreferenceRegionOption.create!(id: 99)
    preference = OrgPreference.create!
    region = OrgPreferenceRegion.create!(preference: preference, option: option)
    assert_includes option.org_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceRegionOption.create!(id: 99)
    preference = OrgPreference.create!
    OrgPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
