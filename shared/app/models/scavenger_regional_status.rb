# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_regional_statuses
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class ScavengerRegionalStatus < BehaviorRecord
  self.record_timestamps = false

  NOTHING = 0
  STARTED = 1
  OK = 2
  ERROR = 3

  has_many :scavenger_regionals,
           class_name: "ScavengerRegional",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :scavenger_regional_status,
           dependent: :restrict_with_error
end
