# frozen_string_literal: true

require "test_helper"

class UserPasskeyStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserPasskeyStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = UserPasskeyStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end
end
