# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_audit_events_on_code  (code) UNIQUE
#
class OrgPreferenceAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :org_preference_audits,
           class_name: "OrgPreferenceAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_preference_audit_event,
           dependent: :restrict_with_error
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
