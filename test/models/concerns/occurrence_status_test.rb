# typed: false
# frozen_string_literal: true

require "test_helper"

class OccurrenceStatusTest < ActiveSupport::TestCase
  class DummyOccurrenceStatus < OccurrenceRecord
    self.table_name = "user_occurrences"
    include OccurrenceStatus
  end

  test "set_default_expires_at runs when expires_at attribute exists" do
    record = DummyOccurrenceStatus.new

    record.expires_at = nil
    record.valid?

    assert_predicate record.expires_at, :present?
  end

  test "skips expires_at when attribute is missing" do
    record = UserOccurrenceStatus.new

    assert_not record.has_attribute?(:expires_at)
    record.valid?

    assert_not record.respond_to?(:expires_at)
  end
end
