# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_behavior_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

class ComDocumentBehaviorLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :com_document_behaviors, dependent: :restrict_with_error, inverse_of: :com_document_behavior_level
end
