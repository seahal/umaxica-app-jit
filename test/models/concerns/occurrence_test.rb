# typed: false
# frozen_string_literal: true

require "test_helper"

class OccurrenceTest < ActiveSupport::TestCase
  test "set_default_lifecycle_timestamps sets defaults when attributes exist" do
    record = UserOccurrence.new

    record.revoked_at = nil
    record.deletable_at = nil
    record.send(:set_default_lifecycle_timestamps)

    assert_occurrence_lifecycle_defaults(record)
  end

  test "set_default_lifecycle_timestamps skips when has_attribute? is false" do
    record = UserOccurrence.new
    record.revoked_at = nil
    record.deletable_at = nil

    record.stub(:has_attribute?, false) do
      record.send(:set_default_lifecycle_timestamps)
    end

    assert_nil record.revoked_at
    assert_nil record.deletable_at
  end
end
