# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class ComContactBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  SUBMITTED = 1
  UPDATED = 2
  VERIFICATION_STARTED = 3
  VERIFICATION_COMPLETED = 4
  DEFAULTS = [NOTHING, SUBMITTED, UPDATED, VERIFICATION_STARTED, VERIFICATION_COMPLETED].freeze

  has_many :com_contact_behaviors,
           class_name: "ComContactBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_contact_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
