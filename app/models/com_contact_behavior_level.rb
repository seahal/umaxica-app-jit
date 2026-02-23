# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class ComContactBehaviorLevel < BehaviorRecord
  self.record_timestamps = false

  NEYO = 1
  DEBUG = 2
  INFO = 3
  WARN = 4
  ERROR = 5

  has_many :com_contact_behaviors, dependent: :restrict_with_error, inverse_of: :com_contact_behavior_level
end
