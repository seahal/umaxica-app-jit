class SetDefaultNoneOnDocumentTimelineStatusIds < ActiveRecord::Migration[8.2]
  TABLES = {
    app_documents: :app_document_status_id,
    app_timelines: :app_timeline_status_id,
    com_documents: :com_document_status_id,
    com_timelines: :com_timeline_status_id,
    org_documents: :org_document_status_id,
    org_timelines: :org_timeline_status_id
  }.freeze

  def change
    TABLES.each do |table, column|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET #{column} = 'NONE' WHERE #{column} IS NULL OR #{column} = ''"
        end
      end

      change_table table, bulk: true do |t|
        t.change_default column, from: "", to: "NONE"
        t.change_null column, false, "NONE"
      end
    end
  end
end
