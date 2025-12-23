require "test_helper"

class UserOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "expires_at default" do
    record = UserOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
