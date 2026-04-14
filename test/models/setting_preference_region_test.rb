# typed: false
# == Schema Information
#
# Table name: settings_preference_regions
# Database name: setting
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_settings_preference_regions_on_option_id      (option_id)
#  index_settings_preference_regions_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_regions_on_option_id      (option_id => settings_preference_region_options.id)
#  fk_settings_preference_regions_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceRegionTest < ActiveSupport::TestCase
  fixtures :settings_preference_region_options

  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(owner_type: "User", owner_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceRegion, :<, SettingRecord
  end

  test "belongs to preference" do
    region = SettingPreferenceRegion.new

    assert_not region.valid?
    assert_not_empty region.errors[:preference]
  end

  test "can be created with preference and option" do
    option = settings_preference_region_options(:jp)
    region = SettingPreferenceRegion.create!(preference: @preference, option: option)

    assert_not_nil region.id
    assert_equal @preference, region.preference
    assert_equal option, region.option
  end

  test "sets default option_id on create" do
    region = SettingPreferenceRegion.create!(preference: @preference)

    assert_equal SettingPreferenceRegionOption::JP, region.option_id
  end

  test "validates uniqueness of preference_id" do
    option = settings_preference_region_options(:jp)
    SettingPreferenceRegion.create!(preference: @preference, option: option)
    duplicate = SettingPreferenceRegion.new(preference: @preference, option: option)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:preference_id]
  end

  test "raises InvalidForeignKey for non-existent arbitrary option_id" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      SettingPreferenceRegion.create!(preference: @preference, option_id: 9999)
    end
  end

  test "SettingPreferenceRegionOption accepts numeric ids" do
    option = SettingPreferenceRegionOption.create!(id: 99)

    assert_predicate option, :persisted?
    region = SettingPreferenceRegion.create!(preference: @preference, option_id: 99)

    assert_equal option, region.option
  end
end
