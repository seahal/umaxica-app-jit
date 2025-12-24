# == Schema Information
#
# Table name: app_contact_audit_events
#
#  id :string(255)      not null, primary key
#

class AppContactAuditEvent < GuestsRecord
  include UppercaseId

  self.table_name = "app_contact_audit_events"

  has_many :app_contact_audits,
           class_name: "AppContactAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_contact_audit_event,
           dependent: :restrict_with_error
end
