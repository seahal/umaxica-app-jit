# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_timeline_audit_events_on_code  (code) UNIQUE
#

require "test_helper"

class OrgTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = OrgTimelineAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
