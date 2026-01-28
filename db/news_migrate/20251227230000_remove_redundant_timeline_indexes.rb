# frozen_string_literal: true

class RemoveRedundantTimelineIndexes < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        remove_index :org_timeline_versions,
                     name: "index_org_timeline_versions_on_org_timeline_id",
                     if_exists: true
        remove_index :org_timeline_tags,
                     name: "index_org_timeline_tags_on_org_timeline_id",
                     if_exists: true
        remove_index :org_timeline_categories,
                     name: "index_org_timeline_categories_on_org_timeline_id",
                     if_exists: true

        remove_index :com_timeline_versions,
                     name: "index_com_timeline_versions_on_com_timeline_id",
                     if_exists: true
        remove_index :com_timeline_tags,
                     name: "index_com_timeline_tags_on_com_timeline_id",
                     if_exists: true
        remove_index :com_timeline_categories,
                     name: "index_com_timeline_categories_on_com_timeline_id",
                     if_exists: true

        remove_index :app_timeline_versions,
                     name: "index_app_timeline_versions_on_app_timeline_id",
                     if_exists: true
        remove_index :app_timeline_tags,
                     name: "index_app_timeline_tags_on_app_timeline_id",
                     if_exists: true
        remove_index :app_timeline_categories,
                     name: "index_app_timeline_categories_on_app_timeline_id",
                     if_exists: true
      end

      dir.down do
        add_index :org_timeline_versions, :org_timeline_id,
                  name: "index_org_timeline_versions_on_org_timeline_id",
                  if_not_exists: true
        add_index :org_timeline_tags, :org_timeline_id,
                  name: "index_org_timeline_tags_on_org_timeline_id",
                  if_not_exists: true
        add_index :org_timeline_categories, :org_timeline_id,
                  name: "index_org_timeline_categories_on_org_timeline_id",
                  if_not_exists: true

        add_index :com_timeline_versions, :com_timeline_id,
                  name: "index_com_timeline_versions_on_com_timeline_id",
                  if_not_exists: true
        add_index :com_timeline_tags, :com_timeline_id,
                  name: "index_com_timeline_tags_on_com_timeline_id",
                  if_not_exists: true
        add_index :com_timeline_categories, :com_timeline_id,
                  name: "index_com_timeline_categories_on_com_timeline_id",
                  if_not_exists: true

        add_index :app_timeline_versions, :app_timeline_id,
                  name: "index_app_timeline_versions_on_app_timeline_id",
                  if_not_exists: true
        add_index :app_timeline_tags, :app_timeline_id,
                  name: "index_app_timeline_tags_on_app_timeline_id",
                  if_not_exists: true
        add_index :app_timeline_categories, :app_timeline_id,
                  name: "index_app_timeline_categories_on_app_timeline_id",
                  if_not_exists: true
      end
    end
  end
end
