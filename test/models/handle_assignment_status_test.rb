# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class HandleAssignmentStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    status = HandleAssignmentStatus.new(id: 9)
    assert_predicate status, :valid?
  end

  test "constants are defined" do
    assert_equal 1, HandleAssignmentStatus::INACTIVE
    assert_equal 2, HandleAssignmentStatus::PENDING
    assert_equal 3, HandleAssignmentStatus::ACTIVE
    assert_equal 4, HandleAssignmentStatus::DELETED
    assert_equal 5, HandleAssignmentStatus::NEYO
  end
end
