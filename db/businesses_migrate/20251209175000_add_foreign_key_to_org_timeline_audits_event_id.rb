class AddForeignKeyToOrgTimelineAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :org_timeline_audits, :org_timeline_audit_events, column: :event_id
  end
end
