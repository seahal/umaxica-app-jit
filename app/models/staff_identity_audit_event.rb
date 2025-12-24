# == Schema Information
#
# Table name: staff_identity_audit_events
#
#  id :string(255)      default("NONE"), not null, primary key
#

class StaffIdentityAuditEvent < IdentitiesRecord
  include UppercaseId

  # Association with staff_identity_audits
  has_many :staff_identity_audits, dependent: :destroy, inverse_of: :staff_identity_audit_event
end
