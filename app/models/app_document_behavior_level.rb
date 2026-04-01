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
  NOTHING = 0
  LEGACY_NOTHING = 1
  DEFAULTS = [NOTHING, LEGACY_NOTHING].freeze

  has_many :app_document_behaviors, dependent: :restrict_with_error, inverse_of: :app_document_behavior_level

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
