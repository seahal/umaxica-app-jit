# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffActivityEventTest < ActiveSupport::TestCase
  setup do
    @model_class = StaffActivityEvent
    @valid_id = StaffActivityEvent::LOGGED_IN
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = StaffActivityEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "all constants are defined with correct values" do
    assert_equal 1, StaffActivityEvent::LOGIN_SUCCESS
    assert_equal 2, StaffActivityEvent::AUTHORIZATION_FAILED
    assert_equal 3, StaffActivityEvent::LOGGED_IN
    assert_equal 4, StaffActivityEvent::LOGGED_OUT
    assert_equal 5, StaffActivityEvent::LOGIN_FAILED
    assert_equal 6, StaffActivityEvent::TOKEN_REFRESHED
    assert_equal 7, StaffActivityEvent::NEYO
    assert_equal 8, StaffActivityEvent::STAFF_SECRET_CREATED
    assert_equal 9, StaffActivityEvent::STAFF_SECRET_REMOVED
    assert_equal 10, StaffActivityEvent::STAFF_SECRET_UPDATED
  end

  test "has_many association with staff_activities" do
    association = StaffActivityEvent.reflect_on_association(:staff_activities)
    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
    assert_equal :event_id, association.options[:foreign_key]
  end
end
