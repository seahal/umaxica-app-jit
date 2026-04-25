# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_regions
# Database name: guest
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_customer_preference_regions_on_option_id      (option_id)
#  index_customer_preference_regions_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => customer_preference_region_options.id)
#  fk_rails_...  (preference_id => customer_preferences.id)
#
require "test_helper"

class CustomerPreferenceRegionTest < ActiveSupport::TestCase
  include PreferenceDetailModelTestHelper

  setup do
    @customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}", status_id: CustomerStatus::NOTHING)
    @other_customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}", status_id: CustomerStatus::NOTHING)
    @preference = CustomerPreference.create!(customer: @customer)
    @other_preference = CustomerPreference.create!(customer: @other_customer)
    @option = CustomerPreferenceRegionOption.find_or_create_by!(id: CustomerPreferenceRegionOption::JP)
  end

  test "validates preference uniqueness and defaults option" do
    assert_preference_detail_model_behavior(
      model_class: CustomerPreferenceRegion,
      preference: @preference,
      default_option_id: CustomerPreferenceRegionOption::JP,
      alternative_preference: @other_preference,
      option: @option,
    )
  end
end
