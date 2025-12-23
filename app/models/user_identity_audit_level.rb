class UserIdentityAuditLevel < IdentityRecord
  include UppercaseId

  has_many :user_identity_audits, dependent: :restrict_with_error, inverse_of: :user_identity_audit_level
end
