# frozen_string_literal: true

# Migration to remove redundant indexes from document revision tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantDocumentRevisionIndexes < ActiveRecord::Migration[7.1]
  def change
    # OrgDocumentRevision
    remove_index :org_document_revisions,
                 column: :org_document_id,
                 name: "index_org_document_revisions_on_org_document_id",
                 if_exists: true

    # ComDocumentRevision
    remove_index :com_document_revisions,
                 column: :com_document_id,
                 name: "index_com_document_revisions_on_com_document_id",
                 if_exists: true

    # AppDocumentRevision
    remove_index :app_document_revisions,
                 column: :app_document_id,
                 name: "index_app_document_revisions_on_app_document_id",
                 if_exists: true
  end
end
