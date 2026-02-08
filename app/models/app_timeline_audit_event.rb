# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

class AppTimelineAuditEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_timeline_audit_event,
           dependent: :restrict_with_error
end
