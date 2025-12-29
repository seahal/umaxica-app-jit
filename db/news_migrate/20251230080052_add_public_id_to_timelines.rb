# frozen_string_literal: true

class AddPublicIdToTimelines < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      change_table :app_timelines, bulk: true do |t|
        t.string :public_id, limit: 21, default: "", null: false
      end
      add_index :app_timelines, :public_id

      change_table :com_timelines, bulk: true do |t|
        t.string :public_id, limit: 21, default: "", null: false
      end
      add_index :com_timelines, :public_id

      change_table :org_timelines, bulk: true do |t|
        t.string :public_id, limit: 21, default: "", null: false
      end
      add_index :org_timelines, :public_id
    end
  end

  def down
    safety_assured do
      remove_index :org_timelines, :public_id
      change_table :org_timelines, bulk: true do |t|
        t.remove :public_id
      end

      remove_index :com_timelines, :public_id
      change_table :com_timelines, bulk: true do |t|
        t.remove :public_id
      end

      remove_index :app_timelines, :public_id
      change_table :app_timelines, bulk: true do |t|
        t.remove :public_id
      end
    end
  end
end
