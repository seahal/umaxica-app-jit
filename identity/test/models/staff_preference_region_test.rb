# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_regions
# Database name: principal
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_staff_preference_regions_on_option_id      (option_id)
#  index_staff_preference_regions_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_staff_preference_regions_on_option_id      (option_id => staff_preference_region_options.id)
#  fk_staff_preference_regions_on_preference_id  (preference_id => staff_preferences.id)
#
require "test_helper"

class StaffPreferenceRegionTest < ActiveSupport::TestCase
  include PreferenceDetailModelTestHelper

  setup do
    @staff = Staff.create!
    @other_staff = Staff.create!
    @preference = StaffPreference.create!(staff: @staff)
    @other_preference = StaffPreference.create!(staff: @other_staff)
    @option = StaffPreferenceRegionOption.find_or_create_by!(id: StaffPreferenceRegionOption::JP)
  end

  test "validates preference uniqueness and defaults option" do
    assert_preference_detail_model_behavior(
      model_class: StaffPreferenceRegion,
      preference: @preference,
      default_option_id: StaffPreferenceRegionOption::JP,
      alternative_preference: @other_preference,
      option: @option,
    )
  end
end
