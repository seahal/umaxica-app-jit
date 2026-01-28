# frozen_string_literal: true

class RemoveTimestampsFromAuditReferenceTables < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_timestamps :app_document_audit_events
      remove_timestamps :app_timeline_audit_events
      remove_timestamps :app_timeline_audit_levels
      remove_timestamps :com_document_audit_events
      remove_timestamps :com_document_audit_levels
      remove_timestamps :com_timeline_audit_events
      remove_timestamps :com_timeline_audit_levels
      remove_timestamps :org_document_audit_events
      remove_timestamps :org_document_audit_levels
      remove_timestamps :org_timeline_audit_events
      remove_timestamps :staff_identity_audit_events
      remove_timestamps :staff_identity_audit_levels
    end
  end
end
