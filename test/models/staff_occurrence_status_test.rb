require "test_helper"

class StaffOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "expires_at default" do
    record = StaffOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
