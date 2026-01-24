# frozen_string_literal: true

require "test_helper"

class OccurrenceTest < ActiveSupport::TestCase
  test "set_default_expires_at sets value when attribute exists" do
    record = UserOccurrence.new

    record.expires_at = nil
    record.send(:set_default_expires_at)

    assert_predicate record.expires_at, :present?
  end

  test "set_default_expires_at skips when has_attribute? is false" do
    record = UserOccurrence.new
    record.expires_at = nil

    record.stub(:has_attribute?, false) do
      record.send(:set_default_expires_at)
    end

    assert_nil record.expires_at
  end
end
