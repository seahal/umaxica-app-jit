# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_user_audit_levels_on_id  (id) UNIQUE
#
class UserAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :user_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_audit_level

  DEFAULTS = %w(NEYO INFO WARN ERROR).freeze

  def self.ensure_defaults!
    DEFAULTS.each do |id|
      find_or_create_by!(id: id)
    end
  end
end
