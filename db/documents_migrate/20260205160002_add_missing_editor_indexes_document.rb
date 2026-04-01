# frozen_string_literal: true

class AddMissingEditorIndexesDocument < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index(:app_document_revisions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)
    add_index(:app_document_versions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)

    add_index(:com_document_revisions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)
    add_index(:com_document_versions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)

    add_index(:org_document_revisions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)
    add_index(:org_document_versions, :edited_by_id, algorithm: :concurrently, if_not_exists: true)
  end
end
