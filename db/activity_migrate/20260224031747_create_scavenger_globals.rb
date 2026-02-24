# frozen_string_literal: true

class CreateScavengerGlobals < ActiveRecord::Migration[8.2]
  def change
    create_table :scavenger_globals, id: :bigserial do |t|
      t.datetime :occurred_at
      t.bigint :event_id, null: false, default: 0
      t.bigint :status_id, null: false, default: 0
      t.string :job_type, limit: 64
      t.jsonb :payload
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :retry_count
      t.string :idempotency_key, limit: 128
      t.text :error_message

      t.timestamps
    end

    safety_assured do
      add_foreign_key :scavenger_globals, :scavenger_global_events, column: :event_id
      add_foreign_key :scavenger_globals, :scavenger_global_statuses, column: :status_id
    end

    add_index :scavenger_globals, :event_id
    add_index :scavenger_globals, :status_id
    add_index :scavenger_globals, :occurred_at
    add_index :scavenger_globals, :job_type
    add_index :scavenger_globals, :idempotency_key, unique: true
  end
end
