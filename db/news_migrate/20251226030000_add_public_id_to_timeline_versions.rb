# frozen_string_literal: true

class AddPublicIdToTimelineVersions < ActiveRecord::Migration[8.2]
  def up
    # Add public_id to app_timeline_versions
    change_table :app_timeline_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :app_timeline_versions, :public_id, unique: true

    # Add public_id to com_timeline_versions
    change_table :com_timeline_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :com_timeline_versions, :public_id, unique: true

    # Add public_id to org_timeline_versions
    change_table :org_timeline_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :org_timeline_versions, :public_id, unique: true
  end

  def down
    # Remove from org_timeline_versions
    remove_index :org_timeline_versions, :public_id
    change_table :org_timeline_versions, bulk: true do |t|
      t.remove :public_id
    end

    # Remove from com_timeline_versions
    remove_index :com_timeline_versions, :public_id
    change_table :com_timeline_versions, bulk: true do |t|
      t.remove :public_id
    end

    # Remove from app_timeline_versions
    remove_index :app_timeline_versions, :public_id
    change_table :app_timeline_versions, bulk: true do |t|
      t.remove :public_id
    end
  end
end
