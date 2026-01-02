# frozen_string_literal: true

class FixDatabaseConsistencyNews < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # Add unique indexes for case-insensitive lookups on timeline masters
    add_index :org_timeline_tag_masters, "lower(id)", unique: true,
                                                      name: "index_org_timeline_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :com_timeline_tag_masters, "lower(id)", unique: true,
                                                      name: "index_com_timeline_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :app_timeline_tag_masters, "lower(id)", unique: true,
                                                      name: "index_app_timeline_tag_masters_on_lower_id",
                                                      algorithm: :concurrently

    add_index :org_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_org_timeline_category_masters_on_lower_id",
                                                           algorithm: :concurrently
    add_index :com_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_com_timeline_category_masters_on_lower_id",
                                                           algorithm: :concurrently
    add_index :app_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_app_timeline_category_masters_on_lower_id",
                                                           algorithm: :concurrently
  end
end
