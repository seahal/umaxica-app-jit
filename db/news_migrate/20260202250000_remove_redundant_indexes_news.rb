# frozen_string_literal: true

class RemoveRedundantIndexesNews < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # OrgTimelineTag
      if index_exists?(:org_timeline_tags, :org_timeline_tag_master_id, name: :index_org_timeline_tags_on_org_timeline_tag_master_id)
        remove_index :org_timeline_tags, name: :index_org_timeline_tags_on_org_timeline_tag_master_id, algorithm: :concurrently
      end
      # ComTimelineTag
      if index_exists?(:com_timeline_tags, :com_timeline_tag_master_id, name: :index_com_timeline_tags_on_com_timeline_tag_master_id)
        remove_index :com_timeline_tags, name: :index_com_timeline_tags_on_com_timeline_tag_master_id, algorithm: :concurrently
      end
      # AppTimelineTag
      if index_exists?(:app_timeline_tags, :app_timeline_tag_master_id, name: :index_app_timeline_tags_on_app_timeline_tag_master_id)
        remove_index :app_timeline_tags, name: :index_app_timeline_tags_on_app_timeline_tag_master_id, algorithm: :concurrently
      end
    end
  end

  def down
    safety_assured do
      add_index :org_timeline_tags, :org_timeline_tag_master_id, name: :index_org_timeline_tags_on_org_timeline_tag_master_id, algorithm: :concurrently
      add_index :com_timeline_tags, :com_timeline_tag_master_id, name: :index_com_timeline_tags_on_com_timeline_tag_master_id, algorithm: :concurrently
      add_index :app_timeline_tags, :app_timeline_tag_master_id, name: :index_app_timeline_tags_on_app_timeline_tag_master_id, algorithm: :concurrently
    end
  end
end
