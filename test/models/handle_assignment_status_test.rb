# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_handle_assignment_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class HandleAssignmentStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = HandleAssignmentStatus.new(id: "VALID_STATUS")
    assert_predicate status, :valid?
  end

  test "validates length of id" do
    record = HandleAssignmentStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
