class AddForeignKeyToComTimelineAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :com_timeline_audits, :com_timeline_audit_events, column: :event_id
  end
end
