# typed: false
# == Schema Information
#
# Table name: app_preference_region_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceRegionOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = AppPreferenceRegionOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many app_preference_regions" do
    option = AppPreferenceRegionOption.create!(id: 99)
    preference = AppPreference.create!
    region = AppPreferenceRegion.create!(preference: preference, option: option)

    assert_includes option.app_preference_regions, region
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceRegionOption.create!(id: 99)
    preference = AppPreference.create!
    AppPreferenceRegion.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns US for US id" do
    option = AppPreferenceRegionOption.find_or_create_by!(id: AppPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns JP for JP id" do
    option = AppPreferenceRegionOption.find_or_create_by!(id: AppPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "name returns nil for NOTHING id" do
    option = AppPreferenceRegionOption.find_or_create_by!(id: AppPreferenceRegionOption::NOTHING)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    AppPreferenceRegionOption.stub(:default_ids, AppPreferenceRegionOption::DEFAULTS) do
      AppPreferenceRegionOption.where(id: AppPreferenceRegionOption::DEFAULTS).delete_all
      AppPreferenceRegionOption.ensure_defaults!

      assert AppPreferenceRegionOption.exists?(AppPreferenceRegionOption::NOTHING)
      assert AppPreferenceRegionOption.exists?(AppPreferenceRegionOption::US)
      assert AppPreferenceRegionOption.exists?(AppPreferenceRegionOption::JP)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    AppPreferenceRegionOption.stub(:default_ids, AppPreferenceRegionOption::DEFAULTS) do
      AppPreferenceRegionOption.ensure_defaults!
      count_before = AppPreferenceRegionOption.where(id: AppPreferenceRegionOption::DEFAULTS).count
      AppPreferenceRegionOption.ensure_defaults!
      count_after = AppPreferenceRegionOption.where(id: AppPreferenceRegionOption::DEFAULTS).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    AppPreferenceRegionOption.stub(:default_ids, []) do
      assert_nothing_raised do
        AppPreferenceRegionOption.ensure_defaults!
      end
    end
  end
end
