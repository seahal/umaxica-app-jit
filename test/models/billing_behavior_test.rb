# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime         not null
#  subject_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  actor_id     :bigint
#  event_id     :bigint           not null
#  level_id     :bigint           not null
#  subject_id   :bigint           not null
#
# Indexes
#
#  index_billing_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_billing_behaviors_on_event_id                     (event_id)
#  index_billing_behaviors_on_level_id                     (level_id)
#  index_billing_behaviors_on_subject_id                   (subject_id)
#  index_billing_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => billing_behavior_events.id)
#  fk_rails_...  (level_id => billing_behavior_levels.id)
#

require "test_helper"

class BillingBehaviorTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "billing_behaviors", BillingBehavior.table_name

    refl = BillingBehavior.reflect_on_association(:billing_record)

    assert_not_nil refl, "expected belongs_to :billing_record association"
    assert_equal :belongs_to, refl.macro

    refl_level = BillingBehavior.reflect_on_association(:billing_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :billing_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "validates subject_id presence" do
    behavior = BillingBehavior.new(
      subject_id: nil,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: BillingBehaviorEvent::CHARGE_CREATED,
      level_id: BillingBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_id], "を入力してください"
  end

  test "validates subject_type presence" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: nil,
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: BillingBehaviorEvent::CHARGE_CREATED,
      level_id: BillingBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:subject_type], "を入力してください"
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 999_999,
      level_id: BillingBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing billing_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: BillingBehaviorEvent::CHARGE_CREATED,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing billing_behavior_level"
  end

  test "event_id rejects negative values" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "event_id rejects decimal values" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      event_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:event_id]
  end

  test "level_id rejects negative values" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: -1,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "level_id rejects decimal values" do
    behavior = BillingBehavior.new(
      subject_id: 1,
      subject_type: "Billing",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
      level_id: 1.5,
    )

    assert_not behavior.valid?
    assert_not_empty behavior.errors[:level_id]
  end

  test "billing_record helper method returns nil when subject_type is not Billing" do
    audit = BillingBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_nil audit.billing_record
  end

  test "billing_record= helper method sets subject_id and subject_type" do
    test_id = 123

    mock_record = Object.new
    mock_record.define_singleton_method(:id) { test_id }

    audit = BillingBehavior.new
    audit.billing_record = mock_record

    assert_equal test_id, audit.subject_id
    assert_equal "Billing", audit.subject_type
  end
end
