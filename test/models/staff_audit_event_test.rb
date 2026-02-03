# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = StaffAuditEvent
    @valid_id = StaffAuditEvent::LOGGED_IN
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = StaffAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end
end
