# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class ComTimelineBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATED = 1

  has_many :com_timeline_behaviors,
           class_name: "ComTimelineBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_behavior_event,
           dependent: :restrict_with_error
end
