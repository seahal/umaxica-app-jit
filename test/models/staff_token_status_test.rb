# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
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
end
