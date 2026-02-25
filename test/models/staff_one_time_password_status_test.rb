# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffOneTimePasswordStatusTest < ActiveSupport::TestCase
  fixtures :staff_one_time_password_statuses

  test "accepts integer ids" do
    status = StaffOneTimePasswordStatus.new(id: 99)

    assert_predicate status, :valid?
    assert_equal 99, status.id
  end

  test "constants are defined" do
    assert_equal 1, StaffOneTimePasswordStatus::ACTIVE
    assert_equal 2, StaffOneTimePasswordStatus::DELETED
    assert_equal 3, StaffOneTimePasswordStatus::INACTIVE
    assert_equal 4, StaffOneTimePasswordStatus::NEYO
    assert_equal 5, StaffOneTimePasswordStatus::REVOKED
  end
end
