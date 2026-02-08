# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgTimelineAuditEvent
    @valid_id = OrgTimelineAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = OrgTimelineAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
