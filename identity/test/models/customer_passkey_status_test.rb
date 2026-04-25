# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_passkey_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerPasskeyStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerPasskeyStatus::ACTIVE
    assert_equal 2, CustomerPasskeyStatus::DISABLED
    assert_equal 3, CustomerPasskeyStatus::REVOKED
    assert_equal 4, CustomerPasskeyStatus::DELETED
    assert_equal 5, CustomerPasskeyStatus::NOTHING
  end

  test "has_many customer_passkeys association is defined" do
    association = CustomerPasskeyStatus.reflect_on_association(:customer_passkeys)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_passkeys has dependent restrict_with_error" do
    association = CustomerPasskeyStatus.reflect_on_association(:customer_passkeys)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerPasskeyStatus.primary_key.to_s
  end
end
