# == Schema Information
#
# Table name: com_contact_audit_events
#
#  id :string(255)      not null, primary key
#

class ComContactAuditEvent < GuestsRecord
  include UppercaseId

  self.table_name = "com_contact_audit_events"

  has_many :com_contact_audits,
           class_name: "ComContactAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_contact_audit_event,
           dependent: :restrict_with_error
end
