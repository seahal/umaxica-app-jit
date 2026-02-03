# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: audit
#
#  id :bigint           not null, primary key
#

class StaffAuditLevel < AuditRecord
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :staff_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_audit_level
end
