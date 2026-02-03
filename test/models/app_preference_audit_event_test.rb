# == Schema Information
#
# Table name: app_preference_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceAuditEventTest < ActiveSupport::TestCase
  fixtures :app_preference_audit_events

  test "accepts integer ids" do
    record = AppPreferenceAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceAuditEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
