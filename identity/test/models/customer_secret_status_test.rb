# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_secret_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerSecretStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, CustomerSecretStatus::ACTIVE
    assert_equal 2, CustomerSecretStatus::EXPIRED
    assert_equal 3, CustomerSecretStatus::REVOKED
    assert_equal 4, CustomerSecretStatus::USED
    assert_equal 5, CustomerSecretStatus::DELETED
    assert_equal 6, CustomerSecretStatus::NOTHING
  end

  test "has_many customer_secrets association is defined" do
    association = CustomerSecretStatus.reflect_on_association(:customer_secrets)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_secrets has dependent restrict_with_error" do
    association = CustomerSecretStatus.reflect_on_association(:customer_secrets)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerSecretStatus.primary_key.to_s
  end
end
