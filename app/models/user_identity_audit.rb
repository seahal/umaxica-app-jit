class UserIdentityAudit < IdentitiesRecord
  belongs_to :user, inverse_of: :user_identity_audits
  belongs_to :user_identity_audit_status, foreign_key: :status_id, inverse_of: :user_identity_audits
end
