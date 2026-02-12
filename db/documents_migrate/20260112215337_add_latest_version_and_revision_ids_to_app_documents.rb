# frozen_string_literal: true

class AddLatestVersionAndRevisionIdsToAppDocuments < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_reference :app_documents, :latest_version,
                    foreign_key: { to_table: :app_document_versions },
                    type: :bigint
      add_reference :app_documents, :latest_revision,
                    foreign_key: { to_table: :app_document_revisions },
                    type: :bigint
    end
  end
end
