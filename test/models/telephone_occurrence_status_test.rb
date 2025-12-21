require "test_helper"

class TelephoneOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "upcases id before validation" do
    assert_upcases_id(TelephoneOccurrenceStatus)
  end

  test "validates id presence" do
    record = TelephoneOccurrenceStatus.new(id: nil)

    assert_invalid_attribute(record, :id)
  end

  test "validates id length" do
    record = TelephoneOccurrenceStatus.new(id: "A" * 256)

    assert_invalid_attribute(record, :id)
  end

  test "validates id format" do
    record = TelephoneOccurrenceStatus.new(id: "BAD-ID!")

    assert_invalid_attribute(record, :id)
  end

  test "validates id uniqueness case insensitive" do
    record = TelephoneOccurrenceStatus.new(id: "active")

    assert_invalid_attribute(record, :id)
  end

  test "has occurrences association" do
    assert_status_association(TelephoneOccurrenceStatus, :telephone_occurrences)
  end
end
