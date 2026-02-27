# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class AppContactBehaviorLevel < BehaviorRecord
  self.record_timestamps = false

  NOTHING = 1
  DEBUG = 2
  INFO = 3
  WARN = 4
  ERROR = 5

  has_many :app_contact_behaviors, dependent: :restrict_with_error, inverse_of: :app_contact_behavior_level
end
