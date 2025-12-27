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
