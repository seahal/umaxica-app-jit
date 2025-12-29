# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_events
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ComTimelineAuditEvent < UniversalRecord
  include UppercaseId

  self.table_name = "com_timeline_audit_events"

  has_many :com_timeline_audits,
           class_name: "ComTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_audit_event,
           dependent: :restrict_with_error
end
