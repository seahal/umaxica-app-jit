# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class BillingBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :billing_behavior_levels, :billing_behavior_events

  test "has correct constants" do
    assert_equal 0, BillingBehaviorLevel::NOTHING
  end

  test "can load nothing status from db" do
    status = BillingBehaviorLevel.find(BillingBehaviorLevel::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "BillingBehaviorLevel.count" do
      BillingBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = BillingBehaviorLevel.find(BillingBehaviorLevel::NOTHING)

    BillingBehaviorEvent.find_or_create_by!(id: BillingBehaviorEvent::CHARGE_CREATED)
    behavior = BillingBehavior.create!(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: BillingBehaviorEvent::CHARGE_CREATED,
      level_id: level.id,
    )

    assert_no_difference "BillingBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "billing behaviorsが存在しているので削除できません", level.errors[:base].first
  ensure
    behavior&.destroy
  end

  test "can destroy when no behaviors exist" do
    level = BillingBehaviorLevel.create!(id: 99)

    assert_difference "BillingBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = BillingBehaviorLevel.new(id: 3)

    assert_predicate record, :valid?
  end
end
