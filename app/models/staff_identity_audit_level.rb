# == Schema Information
#
# Table name: staff_identity_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StaffIdentityAuditLevel < IdentityRecord
  include UppercaseId

  has_many :staff_identity_audits, dependent: :restrict_with_error, inverse_of: :staff_identity_audit_level
end
