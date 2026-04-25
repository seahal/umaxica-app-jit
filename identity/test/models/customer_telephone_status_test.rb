# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_telephone_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerTelephoneStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerTelephoneStatus::UNVERIFIED
    assert_equal 2, CustomerTelephoneStatus::VERIFIED
    assert_equal 3, CustomerTelephoneStatus::SUSPENDED
    assert_equal 4, CustomerTelephoneStatus::DELETED
    assert_equal 5, CustomerTelephoneStatus::NOTHING
    assert_equal 6, CustomerTelephoneStatus::UNVERIFIED_WITH_SIGN_UP
    assert_equal 7, CustomerTelephoneStatus::VERIFIED_WITH_SIGN_UP
  end

  test "has_many customer_telephones association is defined" do
    association = CustomerTelephoneStatus.reflect_on_association(:customer_telephones)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_telephones has dependent restrict_with_error" do
    association = CustomerTelephoneStatus.reflect_on_association(:customer_telephones)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerTelephoneStatus.primary_key.to_s
  end
end
