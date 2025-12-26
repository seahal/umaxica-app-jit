class RebuildAppTimelines < ActiveRecord::Migration[8.2]
  def up
    drop_table :app_timelines, if_exists: true

    create_table :app_timelines, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :permalink, null: false, limit: 200
      t.string :response_mode, null: false, default: "html"
      t.string :redirect_url
      t.string :revision_key, null: false
      t.datetime :published_at, null: false, default: -> { "'infinity'" }
      t.datetime :expires_at, null: false, default: -> { "'infinity'" }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :app_timelines, :permalink, unique: true
    add_index :app_timelines, [ :published_at, :expires_at ]
  end

  def down
    drop_table :app_timelines, if_exists: true

    create_table :app_timelines, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :parent_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.uuid :prev_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.uuid :succ_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.string :title, null: false, default: ""
      t.string :description, null: false, default: ""
      t.string :app_timeline_status_id, limit: 255, null: false, default: "NONE"
      t.uuid :staff_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.string :public_id, limit: 21, null: false, default: ""
      t.timestamps
    end

    add_index :app_timelines, :app_timeline_status_id
    add_index :app_timelines, :parent_id
    add_index :app_timelines, :prev_id
    add_index :app_timelines, :succ_id
    add_index :app_timelines, :staff_id
    add_index :app_timelines, :public_id
  end
end
