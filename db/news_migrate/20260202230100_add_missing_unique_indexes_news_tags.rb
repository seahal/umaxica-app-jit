# frozen_string_literal: true

class AddMissingUniqueIndexesNewsTags < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # OrgTimelineTag
      unless index_exists?(:org_timeline_tags, [:org_timeline_tag_master_id, :org_timeline_id], unique: true)
        remove_index :org_timeline_tags, [:org_timeline_tag_master_id, :org_timeline_id] if index_exists?(:org_timeline_tags, [:org_timeline_tag_master_id, :org_timeline_id])
        add_index :org_timeline_tags, [:org_timeline_tag_master_id, :org_timeline_id], unique: true, name: "idx_org_timeline_tags_on_master_and_timeline", algorithm: :concurrently
      end

      # ComTimelineTag
      unless index_exists?(:com_timeline_tags, [:com_timeline_tag_master_id, :com_timeline_id], unique: true)
        remove_index :com_timeline_tags, [:com_timeline_tag_master_id, :com_timeline_id] if index_exists?(:com_timeline_tags, [:com_timeline_tag_master_id, :com_timeline_id])
        add_index :com_timeline_tags, [:com_timeline_tag_master_id, :com_timeline_id], unique: true, name: "idx_com_timeline_tags_on_master_and_timeline", algorithm: :concurrently
      end

      # AppTimelineTag
      unless index_exists?(:app_timeline_tags, [:app_timeline_tag_master_id, :app_timeline_id], unique: true)
        remove_index :app_timeline_tags, [:app_timeline_tag_master_id, :app_timeline_id] if index_exists?(:app_timeline_tags, [:app_timeline_tag_master_id, :app_timeline_id])
        add_index :app_timeline_tags, [:app_timeline_tag_master_id, :app_timeline_id], unique: true, name: "idx_app_timeline_tags_on_master_and_timeline", algorithm: :concurrently
      end
    end
  end

  def down
  end
end
