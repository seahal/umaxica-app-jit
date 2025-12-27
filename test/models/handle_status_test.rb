require "test_helper"

class HandleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = HandleStatus.new(key: "TEST_STATUS", name: "Test Status")
    assert_predicate status, :valid?
    assert status.save
  end

  test "requires key" do
    status = HandleStatus.new(name: "No Key")
    assert_not status.valid?
    assert_not_empty status.errors[:key]
  end

  test "requires name" do
    status = HandleStatus.new(key: "NONAME")
    assert_not status.valid?
    assert_not_empty status.errors[:name]
  end
end
