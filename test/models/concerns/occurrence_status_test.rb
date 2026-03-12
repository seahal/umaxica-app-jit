# typed: false
# frozen_string_literal: true

require "test_helper"

class OccurrenceStatusTest < ActiveSupport::TestCase
  class DummyOccurrenceStatus < OccurrenceRecord
    self.table_name = "user_occurrences"
    include OccurrenceStatus
  end

  test "set_default_lifecycle_timestamps runs when lifecycle attributes exist" do
    record = DummyOccurrenceStatus.new

    record.revoked_at = nil
    record.deletable_at = nil
    record.valid?

    assert_occurrence_lifecycle_defaults(record)
  end

  test "skips lifecycle timestamps when attributes are missing" do
    record = UserOccurrenceStatus.new

    assert_not record.has_attribute?(:revoked_at)
    assert_not record.has_attribute?(:deletable_at)
    record.valid?

    assert_not record.respond_to?(:revoked_at)
    assert_not record.respond_to?(:deletable_at)
  end
end
