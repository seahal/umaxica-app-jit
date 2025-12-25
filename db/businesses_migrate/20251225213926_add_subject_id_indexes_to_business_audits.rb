class AddSubjectIdIndexesToBusinessAudits < ActiveRecord::Migration[7.1]
  def change
    add_index :org_document_audits, :subject_id, if_not_exists: true
    add_index :org_timeline_audits, :subject_id, if_not_exists: true
    add_index :com_document_audits, :subject_id, if_not_exists: true
    add_index :com_timeline_audits, :subject_id, if_not_exists: true
    add_index :app_document_audits, :subject_id, if_not_exists: true
    add_index :app_timeline_audits, :subject_id, if_not_exists: true
  end
end
