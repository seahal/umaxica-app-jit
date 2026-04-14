# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_region_options
# Database name: guest
#
#  id :bigint           not null, primary key
#
require "test_helper"

class CustomerPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, CustomerPreferenceRegionOption::NOTHING
    assert_equal 1, CustomerPreferenceRegionOption::US
    assert_equal 2, CustomerPreferenceRegionOption::JP
  end

  test "defaults include all fixed ids" do
    assert_includes CustomerPreferenceRegionOption::DEFAULTS, CustomerPreferenceRegionOption::NOTHING
    assert_includes CustomerPreferenceRegionOption::DEFAULTS, CustomerPreferenceRegionOption::US
    assert_includes CustomerPreferenceRegionOption::DEFAULTS, CustomerPreferenceRegionOption::JP
  end

  test "name returns US for US id" do
    option = CustomerPreferenceRegionOption.find_or_create_by!(id: CustomerPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns JP for JP id" do
    option = CustomerPreferenceRegionOption.find_or_create_by!(id: CustomerPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "name returns nil for NOTHING id" do
    option = CustomerPreferenceRegionOption.find_or_create_by!(id: CustomerPreferenceRegionOption::NOTHING)

    assert_nil option.name
  end

  test "has_many customer_preference_regions association is defined" do
    reflection = CustomerPreferenceRegionOption.reflect_on_association(:customer_preference_regions)

    assert_not_nil reflection
    assert_equal :has_many, reflection.macro
  end

  test "ensure_defaults! creates missing default records" do
    CustomerPreferenceRegionOption.ensure_defaults!
    CustomerPreferenceRegionOption.where(id: CustomerPreferenceRegionOption::JP).delete_all

    assert_difference("CustomerPreferenceRegionOption.count", 1) do
      CustomerPreferenceRegionOption.ensure_defaults!
    end
  end

  test "ensure_defaults! skips when all defaults exist" do
    CustomerPreferenceRegionOption.ensure_defaults!

    assert_no_difference("CustomerPreferenceRegionOption.count") do
      CustomerPreferenceRegionOption.ensure_defaults!
    end
  end

  test "inherits from GuestRecord" do
    assert_operator CustomerPreferenceRegionOption, :<, GuestRecord
  end
end
