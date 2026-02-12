# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class ComPreferenceAuditLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  INFO = 1

  has_many :com_preference_audits, dependent: :restrict_with_error, inverse_of: :com_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  DEFAULTS = [INFO].freeze

  def self.ensure_defaults!
    DEFAULTS.each { |id| find_or_create_by!(id: id) }
  end
end
