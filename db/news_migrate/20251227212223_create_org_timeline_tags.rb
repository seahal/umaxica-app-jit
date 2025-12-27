# frozen_string_literal: true

class CreateOrgTimelineTags < ActiveRecord::Migration[8.2]
  def change
    create_table :org_timeline_tags, id: :uuid do |t|
      t.references :org_timeline, null: false, foreign_key: true, type: :uuid
      t.string :org_timeline_tag_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :org_timeline_tags, :org_timeline_tag_masters,
                    column: :org_timeline_tag_master_id, primary_key: :id
    add_index :org_timeline_tags, [:org_timeline_id, :org_timeline_tag_master_id],
              unique: true, name: "index_org_timeline_tags_unique"
  end
end
