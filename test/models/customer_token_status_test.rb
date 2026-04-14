# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerTokenStatusTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 0, CustomerTokenStatus::NOTHING
    assert_equal 1, CustomerTokenStatus::ACTIVE
    assert_equal 2, CustomerTokenStatus::EXPIRED
  end

  test "has_many customer_tokens association is defined" do
    association = CustomerTokenStatus.reflect_on_association(:customer_tokens)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many customer_tokens has dependent restrict_with_error" do
    association = CustomerTokenStatus.reflect_on_association(:customer_tokens)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "uses id as primary key" do
    assert_equal "id", CustomerTokenStatus.primary_key.to_s
  end
end
