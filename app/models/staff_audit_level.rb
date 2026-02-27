# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class StaffAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :staff_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_audit_level
end
