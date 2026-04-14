# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_regions
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
#  index_user_preference_regions_on_option_id      (option_id)
#  index_user_preference_regions_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_user_preference_regions_on_option_id      (option_id => user_preference_region_options.id)
#  fk_user_preference_regions_on_preference_id  (preference_id => user_preferences.id)
#
require "test_helper"

class UserPreferenceRegionTest < ActiveSupport::TestCase
  include PreferenceDetailModelTestHelper

  setup do
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    @other_user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    @preference = UserPreference.create!(user: @user)
    @other_preference = UserPreference.create!(user: @other_user)
    @option = UserPreferenceRegionOption.find_or_create_by!(id: UserPreferenceRegionOption::JP)
  end

  test "validates preference uniqueness and defaults option" do
    assert_preference_detail_model_behavior(
      model_class: UserPreferenceRegion,
      preference: @preference,
      default_option_id: UserPreferenceRegionOption::JP,
      alternative_preference: @other_preference,
      option: @option,
    )
  end
end
