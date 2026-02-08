# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :com_preference_audit_events

  test "accepts integer ids" do
    record = ComPreferenceAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = ComPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
