# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class AppTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = AppTimelineAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
