# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

class ComTimelineAuditEvent < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  CREATED = 1

  has_many :com_timeline_audits,
           class_name: "ComTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_audit_event,
           dependent: :restrict_with_error
end
