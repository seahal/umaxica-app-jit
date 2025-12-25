# == Schema Information
#
# Table name: app_timeline_audit_events
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppTimelineAuditEvent < UniversalRecord
  include UppercaseId

  self.table_name = "app_timeline_audit_events"

  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_timeline_audit_event,
           dependent: :restrict_with_error
end
