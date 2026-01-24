# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
# Database name: token
#
#  id :string(255)      default(""), not null, primary key
#
# Indexes
#
#  index_staff_token_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

require "test_helper"

class StaffTokenStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = StaffTokenStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = StaffTokenStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end

  test "validates length of id" do
    record = StaffTokenStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
