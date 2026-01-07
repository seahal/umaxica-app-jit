# == Schema Information
#
# Table name: com_preference_region_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceRegionOption.create!(id: "TEST_Com_Region")
    assert_not_nil option.id
  end

  test "has many com_preference_regions" do
    option = ComPreferenceRegionOption.create!(id: "TEST_Com_Region")
    preference = ComPreference.create!
    region = ComPreferenceRegion.create!(preference: preference, option: option)
    assert_includes option.com_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceRegionOption.create!(id: "TEST_Com_Region")
    preference = ComPreference.create!
    ComPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
