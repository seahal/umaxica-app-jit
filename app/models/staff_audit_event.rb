# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_staff_audit_events_on_id  (id) UNIQUE
#

class StaffAuditEvent < AuditRecord
  include CodeIdentifiable

  # Association with staff_audits
  has_many :staff_audits,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_audit_event
end
