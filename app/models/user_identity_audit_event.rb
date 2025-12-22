class UserIdentityAuditEvent < IdentitiesRecord
  include UppercaseId

  # Association with user_identity_audits
  has_many :user_identity_audits, dependent: :destroy, inverse_of: :user_identity_audit_event
end
