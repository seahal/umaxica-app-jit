# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#

require "test_helper"

class UserStatusTest < ActiveSupport::TestCase
  def setup
    @status = UserStatus.new(id: 99)
  end

  test "should be valid" do
    assert_predicate @status, :valid?
  end

  test "id should be present" do
    @status.id = nil

    assert_not @status.valid?
  end

  test "id should be unique" do
    duplicate_status = @status.dup
    @status.save

    assert_not duplicate_status.valid?
  end

  test "status constants are defined" do
    expected_status_constants = {
      NEYO: 0,
      NONE: 1,
      GHOST: 2,
      ALIVE: 3,
      ACTIVE: 4,
      INACTIVE: 5,
      PENDING: 6,
      DELETED: 7,
      WITHDRAWN: 8,
      PRE_WITHDRAWAL_CONDITION: 9,
      WITHDRAWAL_COMPLETED: 10,
      UNVERIFIED_WITH_SIGN_UP: 11,
      VERIFIED_WITH_SIGN_UP: 12,
      PENDING_DELETION: 13,
    }

    actual_status_constants =
      expected_status_constants.each_key.with_object({}) do |const_name, hash|
        hash[const_name] = UserStatus.const_get(const_name)
      end

    assert_equal expected_status_constants, actual_status_constants
  end

  test "validates id is non-negative" do
    record = UserStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end
end
