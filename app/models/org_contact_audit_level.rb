class OrgContactAuditLevel < GuestRecord
  include UppercaseId

  has_many :org_contact_audits, foreign_key: :level_id, dependent: :restrict_with_error, inverse_of: :org_contact_audit_level
end
