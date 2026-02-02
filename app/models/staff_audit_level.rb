# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_audit_levels_on_code  (code) UNIQUE
#

class StaffAuditLevel < AuditRecord
  include CodeIdentifiable

  has_many :staff_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_audit_level
end
