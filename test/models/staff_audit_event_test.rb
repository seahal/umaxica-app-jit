# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
# Database name: activity
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

  test "all constants are defined with correct values" do
    assert_equal 1, StaffAuditEvent::LOGIN_SUCCESS
    assert_equal 2, StaffAuditEvent::AUTHORIZATION_FAILED
    assert_equal 3, StaffAuditEvent::LOGGED_IN
    assert_equal 4, StaffAuditEvent::LOGGED_OUT
    assert_equal 5, StaffAuditEvent::LOGIN_FAILED
    assert_equal 6, StaffAuditEvent::TOKEN_REFRESHED
    assert_equal 7, StaffAuditEvent::NEYO
    assert_equal 8, StaffAuditEvent::STAFF_SECRET_CREATED
    assert_equal 9, StaffAuditEvent::STAFF_SECRET_REMOVED
    assert_equal 10, StaffAuditEvent::STAFF_SECRET_UPDATED
  end

  test "has_many association with staff_audits" do
    association = StaffAuditEvent.reflect_on_association(:staff_audits)
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
    assert_equal :event_id, association.options[:foreign_key]
  end
end
