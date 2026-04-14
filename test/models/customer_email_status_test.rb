# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_email_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerEmailStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerEmailStatus::UNVERIFIED
    assert_equal 2, CustomerEmailStatus::VERIFIED
    assert_equal 3, CustomerEmailStatus::SUSPENDED
    assert_equal 4, CustomerEmailStatus::DELETED
    assert_equal 5, CustomerEmailStatus::NOTHING
    assert_equal 6, CustomerEmailStatus::UNVERIFIED_WITH_SIGN_UP
    assert_equal 7, CustomerEmailStatus::VERIFIED_WITH_SIGN_UP
  end

  test "has_many customer_emails association is defined" do
    association = CustomerEmailStatus.reflect_on_association(:customer_emails)

    assert_not_nil association
    assert_equal :has_many, association.macro
    assert_equal :customer_email_status, association.inverse_of.name
  end

  test "has_many customer_emails has dependent restrict_with_error" do
    association = CustomerEmailStatus.reflect_on_association(:customer_emails)

    assert_equal :restrict_with_error, association.options[:dependent]
  end
end
