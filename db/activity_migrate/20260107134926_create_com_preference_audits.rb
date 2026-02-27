# frozen_string_literal: true

class CreateComPreferenceAudits < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preference_audits do |t|
      t.bigint :subject_id, null: false
      t.text :subject_type, null: false
      t.bigint :actor_id, null: false, default: 0
      t.text :actor_type, null: false, default: ""
      t.bigint :event_id, null: false, default: 0
      t.bigint :level_id, null: false, default: 0
      t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :expires_at, null: false, default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }
      t.inet :ip_address, null: false, default: "0.0.0.0"
      t.jsonb :context, null: false, default: {}
      t.text :previous_value, null: false, default: ""
      t.text :current_value, null: false, default: ""

      t.timestamps
    end

    add_index :com_preference_audits, %i(subject_type subject_id occurred_at), name: "idx_on_subject_type_subject_id_occurred_at_com_pref"
    add_index :com_preference_audits, [:actor_id, :occurred_at]
    add_index :com_preference_audits, :subject_id
    add_index :com_preference_audits, :event_id
    add_index :com_preference_audits, :level_id
    add_index :com_preference_audits, :occurred_at
    add_index :com_preference_audits, :expires_at
  end
end
