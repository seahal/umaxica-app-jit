# frozen_string_literal: true

class UserIdentityAudit < IdentitiesRecord
  belongs_to :user, inverse_of: :user_identity_audits
  belongs_to :user_identity_audit_event, foreign_key: :event_id, inverse_of: :user_identity_audits
  belongs_to :actor, polymorphic: true, optional: true

  encrypts :previous_value
end
