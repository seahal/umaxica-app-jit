# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgContactBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgContactBehaviorEvent
    @valid_id = OrgContactBehaviorEvent::SUBMITTED
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, OrgContactBehaviorEvent::NOTHING
    assert_equal 1, OrgContactBehaviorEvent::SUBMITTED
    assert_equal 2, OrgContactBehaviorEvent::UPDATED
    assert_equal 3, OrgContactBehaviorEvent::VERIFICATION_STARTED
    assert_equal 4, OrgContactBehaviorEvent::VERIFICATION_COMPLETED
  end

  test "accepts integer ids" do
    record = OrgContactBehaviorEvent.new(id: 5)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = OrgContactBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    OrgContactBehaviorEvent.ensure_defaults!

    assert_no_difference "OrgContactBehaviorEvent.count" do
      OrgContactBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    OrgContactBehaviorEvent.where(id: OrgContactBehaviorEvent::DEFAULTS).delete_all

    assert_difference "OrgContactBehaviorEvent.count", 5 do
      OrgContactBehaviorEvent.ensure_defaults!
    end

    assert_not_nil OrgContactBehaviorEvent.find_by(id: OrgContactBehaviorEvent::NOTHING)
    assert_not_nil OrgContactBehaviorEvent.find_by(id: OrgContactBehaviorEvent::SUBMITTED)
  end
end
