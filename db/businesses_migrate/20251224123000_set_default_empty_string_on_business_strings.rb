class SetDefaultEmptyStringOnBusinessStrings < ActiveRecord::Migration[8.2]
  def change
    columns = {
      app_document_audits: %i[event_id],
      app_documents: %i[public_id],
      app_timeline_audits: %i[event_id],
      app_timelines: %i[public_id],
      com_document_audits: %i[event_id],
      com_documents: %i[public_id],
      com_timeline_audits: %i[event_id],
      com_timelines: %i[public_id],
      org_document_audits: %i[event_id],
      org_documents: %i[public_id],
      org_timeline_audits: %i[event_id],
      org_timelines: %i[public_id]
    }

    columns.each do |table, cols|
      cols.each do |col|
        change_column_default table, col, from: nil, to: ""
      end
    end
  end
end
