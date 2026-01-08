# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class StaffAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = StaffAuditEvent
    @valid_id = "LOGIN".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = StaffAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
