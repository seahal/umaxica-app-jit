# == Schema Information
#
# Table name: app_preference_region_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceRegionOption.create!(id: "TEST_App_Region")
    assert_not_nil option.id
  end

  test "has many app_preference_regions" do
    option = AppPreferenceRegionOption.create!(id: "TEST_App_Region")
    preference = AppPreference.create!
    region = AppPreferenceRegion.create!(preference: preference, option: option)
    assert_includes option.app_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceRegionOption.create!(id: "TEST_App_Region")
    preference = AppPreference.create!
    AppPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
