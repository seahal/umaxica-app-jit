# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behavior_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
class ComContactBehaviorEvent < ActivityRecord
  self.record_timestamps = false

  NEYO = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :com_contact_behaviors,
           class_name: "ComContactBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_contact_behavior_event,
           dependent: :restrict_with_error
end
