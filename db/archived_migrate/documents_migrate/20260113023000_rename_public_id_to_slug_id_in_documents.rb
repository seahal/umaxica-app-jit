# frozen_string_literal: true

class RenamePublicIdToSlugIdInDocuments < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      rename_column(:app_documents, :public_id, :slug_id)
      rename_column(:com_documents, :public_id, :slug_id)
      rename_column(:org_documents, :public_id, :slug_id)
    end
  end
end
