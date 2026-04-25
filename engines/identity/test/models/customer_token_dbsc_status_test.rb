# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_dbsc_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
require "test_helper"

class CustomerTokenDbscStatusTest < ActiveSupport::TestCase
  test "constants are defined correctly" do
    assert_equal 0, CustomerTokenDbscStatus::NOTHING
    assert_equal 1, CustomerTokenDbscStatus::ACTIVE
    assert_equal 2, CustomerTokenDbscStatus::PENDING
    assert_equal 3, CustomerTokenDbscStatus::FAILED
    assert_equal 4, CustomerTokenDbscStatus::REVOKE
    assert_equal [0, 1, 2, 3, 4], CustomerTokenDbscStatus::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    CustomerTokenDbscStatus.where(id: CustomerTokenDbscStatus::DEFAULTS).destroy_all

    CustomerTokenDbscStatus.ensure_defaults!

    assert CustomerTokenDbscStatus.exists?(id: CustomerTokenDbscStatus::NOTHING)
    assert CustomerTokenDbscStatus.exists?(id: CustomerTokenDbscStatus::ACTIVE)
    assert CustomerTokenDbscStatus.exists?(id: CustomerTokenDbscStatus::PENDING)
    assert CustomerTokenDbscStatus.exists?(id: CustomerTokenDbscStatus::FAILED)
    assert CustomerTokenDbscStatus.exists?(id: CustomerTokenDbscStatus::REVOKE)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    CustomerTokenDbscStatus.ensure_defaults!
    initial_count = CustomerTokenDbscStatus.count

    CustomerTokenDbscStatus.ensure_defaults!

    assert_equal initial_count, CustomerTokenDbscStatus.count
  end

  test "has_many customer_tokens association" do
    status = CustomerTokenDbscStatus.new(id: 1)

    assert_respond_to status, :customer_tokens
  end
end
