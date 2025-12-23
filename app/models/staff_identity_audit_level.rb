class StaffIdentityAuditLevel < IdentityRecord
  include UppercaseId

  has_many :staff_identity_audits, dependent: :restrict_with_error, inverse_of: :staff_identity_audit_level
end
