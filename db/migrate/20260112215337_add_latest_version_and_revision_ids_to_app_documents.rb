# frozen_string_literal: true

class AddLatestVersionAndRevisionIdsToAppDocuments < ActiveRecord::Migration[8.2]
  def change
    add_reference :app_documents, :latest_version,
                  foreign_key: { to_table: :app_document_versions },
                  type: :uuid
    add_reference :app_documents, :latest_revision,
                  foreign_key: { to_table: :app_document_revisions },
                  type: :uuid
  end
end
