# frozen_string_literal: true

class CreateComTimelineCategories < ActiveRecord::Migration[8.2]
  def change
    create_table :com_timeline_categories, id: :uuid do |t|
      t.references :com_timeline, null: false, foreign_key: true, type: :uuid
      t.string :com_timeline_category_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :com_timeline_categories, :com_timeline_category_masters,
                    column: :com_timeline_category_master_id, primary_key: :id
    add_index :com_timeline_categories, :com_timeline_id,
              unique: true, name: "index_com_timeline_categories_unique"
  end
end
