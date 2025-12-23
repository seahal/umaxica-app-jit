class StaffIdentityAudit < IdentitiesRecord
  belongs_to :staff, inverse_of: :staff_identity_audits
  belongs_to :staff_identity_audit_event, foreign_key: :event_id, inverse_of: :staff_identity_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_identity_audit_level, foreign_key: :level_id, inverse_of: :staff_identity_audits

  encrypts :previous_value
end
