# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_colorthemes
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
#  index_staff_preference_colorthemes_on_option_id      (option_id)
#  index_staff_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_staff_preference_colorthemes_on_option_id      (option_id => staff_preference_colortheme_options.id)
#  fk_staff_preference_colorthemes_on_preference_id  (preference_id => staff_preferences.id)
#
require "test_helper"

class StaffPreferenceColorthemeTest < ActiveSupport::TestCase
  include PreferenceDetailModelTestHelper

  setup do
    @staff = Staff.create!
    @other_staff = Staff.create!
    @preference = StaffPreference.create!(staff: @staff)
    @other_preference = StaffPreference.create!(staff: @other_staff)
    @option = StaffPreferenceColorthemeOption.find_or_create_by!(id: StaffPreferenceColorthemeOption::SYSTEM)
  end

  test "validates preference uniqueness and defaults option" do
    assert_preference_detail_model_behavior(
      model_class: StaffPreferenceColortheme,
      preference: @preference,
      default_option_id: StaffPreferenceColorthemeOption::SYSTEM,
      alternative_preference: @other_preference,
      option: @option,
    )
  end
end
