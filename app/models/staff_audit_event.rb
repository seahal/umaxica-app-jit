# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_audit_events_on_code  (code) UNIQUE
#

class StaffAuditEvent < AuditRecord
  include CodeIdentifiable

  # Association with staff_audits
  has_many :staff_audits,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_audit_event
end
