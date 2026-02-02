# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_timeline_audit_events_on_code  (code) UNIQUE
#

class AppTimelineAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_timeline_audit_event,
           dependent: :restrict_with_error
end
