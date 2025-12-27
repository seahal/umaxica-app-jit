# frozen_string_literal: true

class CreateAppTimelineCategories < ActiveRecord::Migration[8.2]
  def change
    create_table :app_timeline_categories, id: :uuid do |t|
      t.references :app_timeline, null: false, foreign_key: true, type: :uuid
      t.string :app_timeline_category_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :app_timeline_categories, :app_timeline_category_masters,
                    column: :app_timeline_category_master_id, primary_key: :id
    add_index :app_timeline_categories, :app_timeline_id,
              unique: true, name: "index_app_timeline_categories_unique"
  end
end
