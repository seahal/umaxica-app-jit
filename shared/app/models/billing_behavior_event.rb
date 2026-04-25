# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class BillingBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  CHARGE_CREATED = 1
  CHARGE_CAPTURED = 2
  CHARGE_FAILED = 3
  REFUND_CREATED = 4
  TAX_CALCULATED = 5
  DEFAULTS = [NOTHING, CHARGE_CREATED, CHARGE_CAPTURED, CHARGE_FAILED, REFUND_CREATED, TAX_CALCULATED].freeze

  has_many :billing_behaviors,
           class_name: "BillingBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :billing_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
