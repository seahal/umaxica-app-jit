# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    expected_status_constants = {
      ACTIVE: 1,
      INACTIVE: 2,
      PENDING: 3,
      DELETED: 4,
      WITHDRAWN: 5,
      PENDING_DELETION: 6,
      PRE_WITHDRAWAL_CONDITION: 7,
      WITHDRAWAL_COMPLETED: 8,
      UNVERIFIED_WITH_SIGN_UP: 9,
      VERIFIED_WITH_SIGN_UP: 10,
      NEYO: 11,
      GHOST: 12,
      NONE: 13,
    }

    actual_status_constants =
      expected_status_constants.each_key.with_object({}) do |const_name, hash|
        hash[const_name] = UserStatus.const_get(const_name)
      end

    assert_equal expected_status_constants, actual_status_constants
  end
end
