# frozen_string_literal: true

class CreateComTimelineTags < ActiveRecord::Migration[8.2]
  def change
    create_table :com_timeline_tags, id: :uuid do |t|
      t.references :com_timeline, null: false, foreign_key: true, type: :uuid
      t.string :com_timeline_tag_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :com_timeline_tags, :com_timeline_tag_masters,
                    column: :com_timeline_tag_master_id, primary_key: :id
    add_index :com_timeline_tags, [:com_timeline_id, :com_timeline_tag_master_id],
              unique: true, name: "index_com_timeline_tags_unique"
  end
end
