# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = UserAuditEvent
    @valid_id = UserAuditEvent::LOGGED_IN
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = UserAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end
end
