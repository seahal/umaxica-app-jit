# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_audit_events_on_code  (code) UNIQUE
#
require "test_helper"

class OrgPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :org_preference_audit_events

  test "upcases id before validation" do
    record = OrgPreferenceAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = OrgPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
