# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_colortheme_options
# Database name: guest
#
#  id :bigint           not null, primary key
#
require "test_helper"

class CustomerPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, CustomerPreferenceColorthemeOption::SYSTEM
    assert_equal 1, CustomerPreferenceColorthemeOption::LIGHT
    assert_equal 2, CustomerPreferenceColorthemeOption::DARK
    assert_equal 3, CustomerPreferenceColorthemeOption::LEGACY_SYSTEM
  end

  test "can load system option from db" do
    option = CustomerPreferenceColorthemeOption.find(CustomerPreferenceColorthemeOption::SYSTEM)

    assert_equal 0, option.id
  end

  test "name returns system for SYSTEM id" do
    option = CustomerPreferenceColorthemeOption.find_or_create_by!(id: CustomerPreferenceColorthemeOption::SYSTEM)

    assert_equal "system", option.name
  end

  test "name returns system for LEGACY_SYSTEM id" do
    option = CustomerPreferenceColorthemeOption.find_or_create_by!(id: CustomerPreferenceColorthemeOption::LEGACY_SYSTEM)

    assert_equal "system", option.name
  end

  test "name returns light for LIGHT id" do
    option = CustomerPreferenceColorthemeOption.find_or_create_by!(id: CustomerPreferenceColorthemeOption::LIGHT)

    assert_equal "light", option.name
  end

  test "name returns dark for DARK id" do
    option = CustomerPreferenceColorthemeOption.find_or_create_by!(id: CustomerPreferenceColorthemeOption::DARK)

    assert_equal "dark", option.name
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "CustomerPreferenceColorthemeOption.count" do
      CustomerPreferenceColorthemeOption.ensure_defaults!
    end
  end
end
