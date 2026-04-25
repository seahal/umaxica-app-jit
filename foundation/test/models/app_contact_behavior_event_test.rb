# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppContactBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppContactBehaviorEvent
    @valid_id = AppContactBehaviorEvent::SUBMITTED
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, AppContactBehaviorEvent::NOTHING
    assert_equal 1, AppContactBehaviorEvent::SUBMITTED
    assert_equal 2, AppContactBehaviorEvent::UPDATED
    assert_equal 3, AppContactBehaviorEvent::VERIFICATION_STARTED
    assert_equal 4, AppContactBehaviorEvent::VERIFICATION_COMPLETED
  end

  test "accepts integer ids" do
    record = AppContactBehaviorEvent.new(id: 5)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = AppContactBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    AppContactBehaviorEvent.ensure_defaults!

    assert_no_difference "AppContactBehaviorEvent.count" do
      AppContactBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    AppContactBehaviorEvent.where(id: AppContactBehaviorEvent::DEFAULTS).delete_all

    assert_difference "AppContactBehaviorEvent.count", 5 do
      AppContactBehaviorEvent.ensure_defaults!
    end

    assert_not_nil AppContactBehaviorEvent.find_by(id: AppContactBehaviorEvent::NOTHING)
    assert_not_nil AppContactBehaviorEvent.find_by(id: AppContactBehaviorEvent::SUBMITTED)
  end
end
