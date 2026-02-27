# frozen_string_literal: true

class AddMissingUniqueIndexesDocumentTags < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # OrgDocumentTag
      unless index_exists?(:org_document_tags, [:org_document_tag_master_id, :org_document_id], unique: true)
        remove_index :org_document_tags, [:org_document_tag_master_id, :org_document_id] if index_exists?(:org_document_tags, [:org_document_tag_master_id, :org_document_id])
        add_index :org_document_tags, [:org_document_tag_master_id, :org_document_id], unique: true, name: "idx_org_document_tags_on_master_and_document", algorithm: :concurrently
      end

      # ComDocumentTag
      unless index_exists?(:com_document_tags, [:com_document_tag_master_id, :com_document_id], unique: true)
        remove_index :com_document_tags, [:com_document_tag_master_id, :com_document_id] if index_exists?(:com_document_tags, [:com_document_tag_master_id, :com_document_id])
        add_index :com_document_tags, [:com_document_tag_master_id, :com_document_id], unique: true, name: "idx_com_document_tags_on_master_and_document", algorithm: :concurrently
      end

      # AppDocumentTag
      unless index_exists?(:app_document_tags, [:app_document_tag_master_id, :app_document_id], unique: true)
        remove_index :app_document_tags, [:app_document_tag_master_id, :app_document_id] if index_exists?(:app_document_tags, [:app_document_tag_master_id, :app_document_id])
        add_index :app_document_tags, [:app_document_tag_master_id, :app_document_id], unique: true, name: "idx_app_document_tags_on_master_and_document", algorithm: :concurrently
      end
    end
  end

  def down
  end
end
