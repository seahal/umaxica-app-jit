# frozen_string_literal: true

class CreateJwtAnomalyEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :jwt_anomaly_events do |t|
      t.bigint :jwt_occurrence_id, null: false
      t.string :code, null: false, default: ""
      t.string :request_host, null: false, default: ""
      t.string :kid, null: false, default: ""
      t.string :alg, null: false, default: ""
      t.string :typ, null: false, default: ""
      t.string :issuer, null: false, default: ""
      t.string :jti, null: false, default: ""
      t.string :error_class, null: false, default: ""
      t.string :error_message, null: false, default: ""
      t.jsonb :metadata, null: false, default: {}
      t.timestamptz :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps
    end

    add_index :jwt_anomaly_events, :jwt_occurrence_id
    add_index :jwt_anomaly_events, :code
    add_index :jwt_anomaly_events, :occurred_at
    add_foreign_key :jwt_anomaly_events, :jwt_occurrences,
                    column: :jwt_occurrence_id,
                    name: "fk_jwt_anomaly_events_on_jwt_occurrence_id",
                    validate: false
  end
end
