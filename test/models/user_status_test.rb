# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_user_statuses_on_id  (id) UNIQUE
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
    assert_equal 0, UserStatus::NEYO
    assert_equal 1, UserStatus::NONE
    assert_equal 2, UserStatus::GHOST
    assert_equal 3, UserStatus::ALIVE
    assert_equal 4, UserStatus::ACTIVE
    assert_equal 5, UserStatus::INACTIVE
    assert_equal 6, UserStatus::PENDING
    assert_equal 7, UserStatus::DELETED
    assert_equal 8, UserStatus::WITHDRAWN
    assert_equal 9, UserStatus::PRE_WITHDRAWAL_CONDITION
    assert_equal 10, UserStatus::WITHDRAWAL_COMPLETED
    assert_equal 11, UserStatus::UNVERIFIED_WITH_SIGN_UP
    assert_equal 12, UserStatus::VERIFIED_WITH_SIGN_UP
    assert_equal 13, UserStatus::PENDING_DELETION
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
