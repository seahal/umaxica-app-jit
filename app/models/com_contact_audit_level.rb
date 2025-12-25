class ComContactAuditLevel < GuestRecord
  include UppercaseId

  has_many :com_contact_audits, foreign_key: :level_id, dependent: :restrict_with_error, inverse_of: :com_contact_audit_level
end
