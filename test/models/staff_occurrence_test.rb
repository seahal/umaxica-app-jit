require "test_helper"

class StaffOccurrenceTest < ActiveSupport::TestCase
  include OccurrenceTestHelper

  test "expires_at default" do
    record = build_occurrence(StaffOccurrence, body: "staff-occur-1", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
