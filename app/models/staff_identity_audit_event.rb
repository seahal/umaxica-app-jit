# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_audit_events
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class StaffIdentityAuditEvent < UniversalRecord
  include UppercaseId

  # Association with staff_identity_audits
  has_many :staff_identity_audits,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_identity_audit_event
end
