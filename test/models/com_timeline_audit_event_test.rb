# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_timeline_audit_events_on_code  (code) UNIQUE
#

require "test_helper"

class ComTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = ComTimelineAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
