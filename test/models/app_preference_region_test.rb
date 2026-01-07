# == Schema Information
#
# Table name: app_preference_regions
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_app_preference_regions_on_option_id      (option_id)
#  index_app_preference_regions_on_preference_id  (preference_id)
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceRegionTest < ActiveSupport::TestCase
  setup do
    @preference = AppPreference.create!
  end

  test "belongs to preference" do
    region = AppPreferenceRegion.new
    assert_not region.valid?
    assert_includes region.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    region = AppPreferenceRegion.create!(preference: @preference)
    assert_not_nil region.id
    assert_equal @preference, region.preference
  end

  test "can be created with option" do
    option = AppPreferenceRegionOption.create!
    region = AppPreferenceRegion.create!(preference: @preference, option: option)
    assert_equal option, region.option
  end

  test "can be created without option" do
    region = AppPreferenceRegion.create!(preference: @preference)
    assert_nil region.option
  end

  test "validates uniqueness of preference" do
    AppPreferenceRegion.create!(preference: @preference)
    duplicate_region = AppPreferenceRegion.new(preference: @preference)
    assert_not duplicate_region.valid?
    assert_includes duplicate_region.errors[:preference_id], "はすでに存在します"
  end
end
