# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_events
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_com_timeline_audit_events_on_id  (id) UNIQUE
#

class ComTimelineAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :com_timeline_audits,
           class_name: "ComTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_audit_event,
           dependent: :restrict_with_error
end
