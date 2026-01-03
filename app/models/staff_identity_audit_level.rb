# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_audit_levels
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class StaffIdentityAuditLevel < UniversalRecord
  include UppercaseId

  has_many :staff_identity_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_identity_audit_level
end
