# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class AppContactBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  NOTHING = 0
  SUBMITTED = 1
  UPDATED = 2
  VERIFICATION_STARTED = 3
  VERIFICATION_COMPLETED = 4
  DEFAULTS = [NOTHING, SUBMITTED, UPDATED, VERIFICATION_STARTED, VERIFICATION_COMPLETED].freeze

  has_many :app_contact_behaviors,
           class_name: "AppContactBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_contact_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
