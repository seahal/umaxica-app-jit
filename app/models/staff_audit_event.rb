# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

class StaffAuditEvent < AuditRecord
  # Fixed IDs - do not modify these values
  LOGIN_SUCCESS = 1
  AUTHORIZATION_FAILED = 2
  LOGGED_IN = 3
  LOGGED_OUT = 4
  LOGIN_FAILED = 5
  TOKEN_REFRESHED = 6
  NEYO = 7
  STAFF_SECRET_CREATED = 8
  STAFF_SECRET_REMOVED = 9
  STAFF_SECRET_UPDATED = 10

  # Association with staff_audits
  has_many :staff_audits,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_audit_event
end
