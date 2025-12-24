# == Schema Information
#
# Table name: user_identity_audit_events
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserIdentityAuditEvent < IdentitiesRecord
  include UppercaseId

  # Association with user_identity_audits
  has_many :user_identity_audits, dependent: :restrict_with_error, inverse_of: :user_identity_audit_event
end
