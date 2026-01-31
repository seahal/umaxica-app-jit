# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_staff_audit_levels_on_id  (id) UNIQUE
#

class StaffAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :staff_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_audit_level
end
