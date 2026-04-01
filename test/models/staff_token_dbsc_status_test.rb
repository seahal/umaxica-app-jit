# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_dbsc_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffTokenDbscStatusTest < ActiveSupport::TestCase
  test "constants are defined correctly" do
    assert_equal 0, StaffTokenDbscStatus::NOTHING
    assert_equal 1, StaffTokenDbscStatus::PENDING
    assert_equal 2, StaffTokenDbscStatus::ACTIVE
    assert_equal 3, StaffTokenDbscStatus::FAILED
    assert_equal 4, StaffTokenDbscStatus::REVOKE
    assert_equal [0, 1, 2, 3, 4], StaffTokenDbscStatus::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    StaffTokenDbscStatus.where(id: StaffTokenDbscStatus::DEFAULTS).destroy_all

    StaffTokenDbscStatus.ensure_defaults!

    assert StaffTokenDbscStatus.exists?(id: StaffTokenDbscStatus::NOTHING)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    StaffTokenDbscStatus.ensure_defaults!
    initial_count = StaffTokenDbscStatus.count

    StaffTokenDbscStatus.ensure_defaults!

    assert_equal initial_count, StaffTokenDbscStatus.count
  end

  test "has_many staff_tokens association" do
    status = StaffTokenDbscStatus.new(id: 1)

    assert_respond_to status, :staff_tokens
  end
end
