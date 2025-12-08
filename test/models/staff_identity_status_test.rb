require "test_helper"

class StaffIdentityStatusTest < ActiveSupport::TestCase
  def setup
    @status = StaffIdentityStatus.new(id: "VALID_ID")
  end

  test "should be valid" do
    assert_predicate @status, :valid?
  end

  test "id should be present" do
    @status.id = nil

    assert_not @status.valid?
    @status.id = "   "

    assert_not @status.valid?
    @status.id = ""

    assert_not @status.valid?
  end

  test "id should not be too long" do
    @status.id = "a" * 255

    assert_predicate @status, :valid?
    @status.id = "a" * 256

    assert_not @status.valid?
  end

  test "id should be unique" do
    duplicate_status = @status.dup
    @status.save

    assert_not duplicate_status.valid?
  end
end
