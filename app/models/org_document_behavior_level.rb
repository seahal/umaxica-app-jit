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
  NOTHING = 1
  DEFAULTS = [NOTHING].freeze

  has_many :org_document_behaviors, dependent: :restrict_with_error, inverse_of: :org_document_behavior_level

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
