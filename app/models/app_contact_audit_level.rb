class AppContactAuditLevel < GuestRecord
  include UppercaseId

  has_many :app_contact_audits, foreign_key: :level_id, dependent: :restrict_with_error, inverse_of: :app_contact_audit_level
end
