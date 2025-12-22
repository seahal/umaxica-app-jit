require "test_helper"

class UserOccurrenceTest < ActiveSupport::TestCase
  include OccurrenceTestHelper

  test "expires_at default" do
    record = build_occurrence(UserOccurrence, body: "user-occur-1", public_id: "Y" * 21)

    assert_expires_at_default(record)
  end
end
