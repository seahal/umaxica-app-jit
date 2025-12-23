require "test_helper"

class IpOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "upcases id before validation" do
    assert_upcases_id(IpOccurrenceStatus)
  end

  test "validates id presence" do
    record = IpOccurrenceStatus.new(id: nil)

    assert_invalid_attribute(record, :id)
  end

  test "validates id length" do
    record = IpOccurrenceStatus.new(id: "A" * 256)

    assert_invalid_attribute(record, :id)
  end

  test "validates id format" do
    record = IpOccurrenceStatus.new(id: "BAD-ID!")

    assert_invalid_attribute(record, :id)
  end

  test "validates id uniqueness case insensitive" do
    record = IpOccurrenceStatus.new(id: "active")

    assert_invalid_attribute(record, :id)
  end

  test "has occurrences association" do
    assert_status_association(IpOccurrenceStatus, :ip_occurrences)
  end

  test "expires_at default" do
    record = IpOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
