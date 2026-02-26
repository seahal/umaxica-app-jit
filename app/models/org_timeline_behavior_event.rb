# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class OrgTimelineBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :org_timeline_behaviors,
           class_name: "OrgTimelineBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_behavior_event,
           dependent: :restrict_with_error
end
