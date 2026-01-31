# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#
require "test_helper"

class ComPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :com_preference_audit_events

  test "upcases id before validation" do
    record = ComPreferenceAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = ComPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
