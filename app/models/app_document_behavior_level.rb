# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class AppDocumentBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 1
  has_many :app_document_behaviors, dependent: :restrict_with_error, inverse_of: :app_document_behavior_level
end
