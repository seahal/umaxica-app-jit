# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComTimelineAuditEvent
    @valid_id = ComTimelineAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = ComTimelineAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
