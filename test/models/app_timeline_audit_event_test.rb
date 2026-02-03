# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppTimelineAuditEvent
    @valid_id = AppTimelineAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = AppTimelineAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
