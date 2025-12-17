# frozen_string_literal: true

class StaffIdentityAuditEvent < IdentitiesRecord
  include UppercaseIdValidation

  # Association with staff_identity_audits
  has_many :staff_identity_audits, dependent: :destroy, inverse_of: :staff_identity_audit_event
end
