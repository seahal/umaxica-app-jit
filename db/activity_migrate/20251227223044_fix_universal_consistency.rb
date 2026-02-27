# frozen_string_literal: true

class FixUniversalConsistency < ActiveRecord::Migration[8.2]
  def change
    # Timeline Audits
    add_index :org_timeline_audits, :subject_id, if_not_exists: true
    add_index :com_timeline_audits, :subject_id, if_not_exists: true
    add_index :app_timeline_audits, :subject_id, if_not_exists: true

    # Document Audits
    add_index :org_document_audits, :subject_id, if_not_exists: true
    add_index :com_document_audits, :subject_id, if_not_exists: true
    add_index :app_document_audits, :subject_id, if_not_exists: true

    # Identity Audits
    add_index :user_identity_audits, :subject_id, if_not_exists: true
    add_index :staff_identity_audits, :subject_id, if_not_exists: true
  end
end
