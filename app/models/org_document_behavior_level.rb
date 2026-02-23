# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class OrgDocumentBehaviorLevel < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :org_document_behaviors, dependent: :restrict_with_error, inverse_of: :org_document_behavior_level
end
