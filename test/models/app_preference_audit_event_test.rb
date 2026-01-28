# == Schema Information
#
# Table name: app_preference_audit_events
# Database name: audit
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :app_preference_audit_events

  test "validates length of id" do
    record = AppPreferenceAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "upcases id before validation" do
    record = AppPreferenceAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end

  test "handles nil id gracefully" do
    record = AppPreferenceAuditEvent.new(id: nil)
    record.valid?
    assert_nil record.id
    assert_predicate record.errors[:id], :any?
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
