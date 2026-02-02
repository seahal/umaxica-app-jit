# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_handle_assignment_statuses_on_code  (code) UNIQUE
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
