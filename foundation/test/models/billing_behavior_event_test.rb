# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class BillingBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = BillingBehaviorEvent
    @valid_id = BillingBehaviorEvent::CHARGE_CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "has correct constants" do
    assert_equal 0, BillingBehaviorEvent::NOTHING
    assert_equal 1, BillingBehaviorEvent::CHARGE_CREATED
    assert_equal 2, BillingBehaviorEvent::CHARGE_CAPTURED
    assert_equal 3, BillingBehaviorEvent::CHARGE_FAILED
    assert_equal 4, BillingBehaviorEvent::REFUND_CREATED
    assert_equal 5, BillingBehaviorEvent::TAX_CALCULATED
  end

  test "accepts integer ids" do
    record = BillingBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = BillingBehaviorEvent.new(id: nil)

    assert_predicate record, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "BillingBehaviorEvent.count" do
      BillingBehaviorEvent.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing defaults" do
    BillingBehaviorEvent.where(id: BillingBehaviorEvent::DEFAULTS).delete_all

    assert_difference "BillingBehaviorEvent.count", 6 do
      BillingBehaviorEvent.ensure_defaults!
    end

    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::NOTHING)
    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::CHARGE_CREATED)
    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::CHARGE_CAPTURED)
    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::CHARGE_FAILED)
    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::REFUND_CREATED)
    assert_not_nil BillingBehaviorEvent.find_by(id: BillingBehaviorEvent::TAX_CALCULATED)
  end
end
