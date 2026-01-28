# frozen_string_literal: true

class RemoveRedundantDocumentIndexes < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        remove_index :org_document_versions,
                     name: "index_org_document_versions_on_org_document_id",
                     if_exists: true
        remove_index :org_document_tags,
                     name: "index_org_document_tags_on_org_document_id",
                     if_exists: true

        remove_index :com_document_versions,
                     name: "index_com_document_versions_on_com_document_id",
                     if_exists: true
        remove_index :com_document_tags,
                     name: "index_com_document_tags_on_com_document_id",
                     if_exists: true

        remove_index :app_document_versions,
                     name: "index_app_document_versions_on_app_document_id",
                     if_exists: true
        remove_index :app_document_tags,
                     name: "index_app_document_tags_on_app_document_id",
                     if_exists: true
      end

      dir.down do
        add_index :org_document_versions, :org_document_id,
                  name: "index_org_document_versions_on_org_document_id",
                  if_not_exists: true
        add_index :org_document_tags, :org_document_id,
                  name: "index_org_document_tags_on_org_document_id",
                  if_not_exists: true

        add_index :com_document_versions, :com_document_id,
                  name: "index_com_document_versions_on_com_document_id",
                  if_not_exists: true
        add_index :com_document_tags, :com_document_id,
                  name: "index_com_document_tags_on_com_document_id",
                  if_not_exists: true

        add_index :app_document_versions, :app_document_id,
                  name: "index_app_document_versions_on_app_document_id",
                  if_not_exists: true
        add_index :app_document_tags, :app_document_id,
                  name: "index_app_document_tags_on_app_document_id",
                  if_not_exists: true
      end
    end
  end
end
