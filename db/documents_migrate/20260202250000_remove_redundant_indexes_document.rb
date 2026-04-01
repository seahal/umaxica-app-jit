# frozen_string_literal: true

class RemoveRedundantIndexesDocument < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # OrgDocumentTag
      if index_exists?(
        :org_document_tags, :org_document_tag_master_id,
        name: :index_org_document_tags_on_org_document_tag_master_id,
      )
        remove_index(
          :org_document_tags, name: :index_org_document_tags_on_org_document_tag_master_id,
                              algorithm: :concurrently,
        )
      end
      # ComDocumentTag
      if index_exists?(
        :com_document_tags, :com_document_tag_master_id,
        name: :index_com_document_tags_on_com_document_tag_master_id,
      )
        remove_index(
          :com_document_tags, name: :index_com_document_tags_on_com_document_tag_master_id,
                              algorithm: :concurrently,
        )
      end
      # AppDocumentTag
      if index_exists?(
        :app_document_tags, :app_document_tag_master_id,
        name: :index_app_document_tags_on_app_document_tag_master_id,
      )
        remove_index(
          :app_document_tags, name: :index_app_document_tags_on_app_document_tag_master_id,
                              algorithm: :concurrently,
        )
      end
    end
  end

  def down
    safety_assured do
      add_index(
        :org_document_tags, :org_document_tag_master_id,
        name: :index_org_document_tags_on_org_document_tag_master_id, algorithm: :concurrently,
      )
      add_index(
        :com_document_tags, :com_document_tag_master_id,
        name: :index_com_document_tags_on_com_document_tag_master_id, algorithm: :concurrently,
      )
      add_index(
        :app_document_tags, :app_document_tag_master_id,
        name: :index_app_document_tags_on_app_document_tag_master_id, algorithm: :concurrently,
      )
    end
  end
end
