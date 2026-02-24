# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_global_statuses
# Database name: activity
#
#  id :bigint           not null, primary key
#
class ScavengerGlobalStatus < ActivityRecord
  self.record_timestamps = false

  NOTHING = 0
  STARTED = 1
  OK = 2
  ERROR = 3

  has_many :scavenger_globals,
           class_name: "ScavengerGlobal",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :scavenger_global_status,
           dependent: :restrict_with_error
end
