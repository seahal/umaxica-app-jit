# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_levels
# Database name: audit
#
#  id :bigint           not null, primary key
#
class UserAuditLevel < AuditRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  DEBUG = 1
  ERROR = 2
  INFO = 3
  NEYO = 4
  WARN = 5

  has_many :user_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_audit_level

  DEFAULTS = [NEYO, INFO, WARN, ERROR].freeze

  def self.ensure_defaults!
    DEFAULTS.each do |id|
      find_or_create_by!(id: id)
    end
  end
end
