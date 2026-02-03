# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#
require "test_helper"

class OrgPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :org_preference_audit_events

  test "accepts integer ids" do
    record = OrgPreferenceAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = OrgPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
