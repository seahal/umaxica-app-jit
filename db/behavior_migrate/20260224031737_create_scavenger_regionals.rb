# frozen_string_literal: true

class CreateScavengerRegionals < ActiveRecord::Migration[8.2]
  def change
    create_table(:scavenger_regionals, id: :bigserial) do |t|
      t.bigint(:region_id, null: false)
      t.datetime(:occurred_at)
      t.bigint(:event_id, null: false, default: 0)
      t.bigint(:status_id, null: false, default: 0)
      t.string(:job_type, limit: 64, null: false)
      t.jsonb(:payload)
      t.datetime(:started_at)
      t.datetime(:finished_at)
      t.integer(:retry_count)
      t.string(:idempotency_key, limit: 128, null: false)
      t.text(:error_message)

      t.timestamps
    end

    safety_assured do
      add_foreign_key(:scavenger_regionals, :scavenger_regional_events, column: :event_id)
      add_foreign_key(:scavenger_regionals, :scavenger_regional_statuses, column: :status_id)
    end

    add_index(:scavenger_regionals, :event_id)
    add_index(:scavenger_regionals, :status_id)
    add_index(:scavenger_regionals, :occurred_at)
    add_index(:scavenger_regionals, %i(region_id job_type))
    add_index(:scavenger_regionals, %i(region_id idempotency_key), unique: true)
  end
end
