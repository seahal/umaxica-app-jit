# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_global_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
class ScavengerGlobalEvent < ActivityRecord
  self.record_timestamps = false

  NOTHING = 0
  CREATED = 1
  STARTED = 2
  FINISHED = 3
  FAILED = 4

  has_many :scavenger_globals,
           class_name: "ScavengerGlobal",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :scavenger_global_event,
           dependent: :restrict_with_error
end
