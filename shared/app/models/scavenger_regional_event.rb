# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_regional_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class ScavengerRegionalEvent < BehaviorRecord
  self.record_timestamps = false

  NOTHING = 0
  CREATED = 1
  STARTED = 2
  FINISHED = 3
  FAILED = 4

  has_many :scavenger_regionals,
           class_name: "ScavengerRegional",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :scavenger_regional_event,
           dependent: :restrict_with_error
end
