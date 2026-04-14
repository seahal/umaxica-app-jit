# typed: false
# == Schema Information
#
# Table name: com_preference_region_options
# Database name: commerce
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceRegionOptionTest < ActiveSupport::TestCase
  setup do
    ComPreferenceStatus.find_or_create_by!(id: ComPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = ComPreferenceRegionOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many com_preference_regions" do
    option = ComPreferenceRegionOption.create!(id: 99)
    preference = ComPreference.create!
    region = ComPreferenceRegion.create!(preference: preference, option: option)

    assert_includes option.com_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceRegionOption.create!(id: 99)
    preference = ComPreference.create!
    ComPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns US for US id" do
    option = ComPreferenceRegionOption.find_or_create_by!(id: ComPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns JP for JP id" do
    option = ComPreferenceRegionOption.find_or_create_by!(id: ComPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2], ComPreferenceRegionOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    ComPreferenceRegionOption.where(id: ComPreferenceRegionOption::DEFAULTS).destroy_all

    ComPreferenceRegionOption.ensure_defaults!

    assert ComPreferenceRegionOption.exists?(id: ComPreferenceRegionOption::US)
    assert ComPreferenceRegionOption.exists?(id: ComPreferenceRegionOption::JP)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    ComPreferenceRegionOption.ensure_defaults!
    initial_count = ComPreferenceRegionOption.count

    ComPreferenceRegionOption.ensure_defaults!

    assert_equal initial_count, ComPreferenceRegionOption.count
  end
end
