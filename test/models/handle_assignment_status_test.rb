# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
#
#  id          :string           not null, primary key
#  key         :string           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_handle_assignment_statuses_on_key  (key) UNIQUE
#

require "test_helper"

class HandleAssignmentStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = HandleAssignmentStatus.new(key: "TEST_STATUS", name: "Test Status")
    assert_predicate status, :valid?
    assert status.save
  end

  test "requires key" do
    status = HandleAssignmentStatus.new(name: "No Key")
    assert_not status.valid?
    assert_not_empty status.errors[:key]
  end

  test "requires name" do
    status = HandleAssignmentStatus.new(key: "NONAME")
    assert_not status.valid?
    assert_not_empty status.errors[:name]
  end
end
