# == Schema Information
#
# Table name: com_preference_regions
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_com_preference_regions_on_option_id      (option_id)
#  index_com_preference_regions_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceRegionTest < ActiveSupport::TestCase
  setup do
    @preference = ComPreference.create!
  end

  test "belongs to preference" do
    region = ComPreferenceRegion.new
    assert_not region.valid?
    assert_includes region.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    region = ComPreferenceRegion.create!(preference: @preference)
    assert_not_nil region.id
    assert_equal @preference, region.preference
  end

  test "can be created with option" do
    option = ComPreferenceRegionOption.create!(id: "TEST_COM_REGION")
    region = ComPreferenceRegion.create!(preference: @preference, option: option)
    assert_equal option, region.option
  end

  test "can be created without option" do
    region = ComPreferenceRegion.create!(preference: @preference)
    assert_nil region.option
  end
end
