# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class ComTimelineBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 1
  has_many :com_timeline_behaviors, dependent: :restrict_with_error, inverse_of: :com_timeline_behavior_level
end
