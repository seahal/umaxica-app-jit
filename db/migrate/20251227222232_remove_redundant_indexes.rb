# frozen_string_literal: true

class RemoveRedundantIndexes < ActiveRecord::Migration[8.2]
  def change
    remove_index :org_timeline_versions, :org_timeline_id
    remove_index :org_timeline_tags, :org_timeline_id
    remove_index :org_timeline_categories, :org_timeline_id
    remove_index :com_timeline_versions, :com_timeline_id
    remove_index :com_timeline_tags, :com_timeline_id
    remove_index :com_timeline_categories, :com_timeline_id
    remove_index :app_timeline_versions, :app_timeline_id
    remove_index :app_timeline_tags, :app_timeline_id
    remove_index :app_timeline_categories, :app_timeline_id
    remove_index :org_document_versions, :org_document_id
    remove_index :org_document_tags, :org_document_id
    remove_index :com_document_versions, :com_document_id
    remove_index :com_document_tags, :com_document_id
    remove_index :app_document_versions, :app_document_id
    remove_index :app_document_tags, :app_document_id
  end
end
