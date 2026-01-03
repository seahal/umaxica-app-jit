# frozen_string_literal: true

class AddUniqueIndexesForTimelineMasterIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index :org_timeline_tag_masters, "lower(id)", unique: true, name: "index_org_timeline_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :com_timeline_tag_masters, "lower(id)", unique: true, name: "index_com_timeline_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :app_timeline_tag_masters, "lower(id)", unique: true, name: "index_app_timeline_tag_masters_on_lower_id",
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
