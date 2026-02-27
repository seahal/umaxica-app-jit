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

  NOTHING = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :app_contact_behaviors,
           class_name: "AppContactBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_contact_behavior_event,
           dependent: :restrict_with_error
end
