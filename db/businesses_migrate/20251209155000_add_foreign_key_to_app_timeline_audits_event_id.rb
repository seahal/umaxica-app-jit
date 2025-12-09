class AddForeignKeyToAppTimelineAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :app_timeline_audits, :app_timeline_audit_events, column: :event_id
  end
end
