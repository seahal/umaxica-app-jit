# frozen_string_literal: true

class CreateAppTimelineTags < ActiveRecord::Migration[8.2]
  def change
    create_table :app_timeline_tags, id: :uuid do |t|
      t.references :app_timeline, null: false, foreign_key: true, type: :uuid
      t.string :app_timeline_tag_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :app_timeline_tags, :app_timeline_tag_masters,
                    column: :app_timeline_tag_master_id, primary_key: :id
    add_index :app_timeline_tags, [:app_timeline_id, :app_timeline_tag_master_id],
              unique: true, name: "index_app_timeline_tags_unique"
  end
end
