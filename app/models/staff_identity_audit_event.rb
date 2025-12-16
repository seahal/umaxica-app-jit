# frozen_string_literal: true

class StaffIdentityAuditEvent < IdentitiesRecord
  include UppercaseIdValidation

  # staff_identity_audits との関連付け
  has_many :staff_identity_audits, dependent: :destroy, inverse_of: :staff_identity_audit_event
end
