# frozen_string_literal: true

class RestoreIdentityAuditTables < ActiveRecord::Migration[7.1]
  def change
    # Recreate User Identity Audit Tables
    create_table :user_identity_audit_events, id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
      t.timestamps
    end

    create_table :user_identity_audit_levels, id: :string, default: "NONE", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table :user_identity_audits, id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
      t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
      t.string "actor_type", default: "", null: false
      t.datetime "created_at", null: false
      t.string "event_id", limit: 255, default: "", null: false
      t.string "ip_address", default: "", null: false
      t.string "level_id", default: "NONE", null: false
      t.string "subject_id"
      t.string "subject_type", default: "", null: false
      t.text "previous_value"
      t.datetime "timestamp", null: false
      t.datetime "updated_at", null: false
      t.uuid "user_id", null: false
      t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
      t.index ["level_id"], name: "index_user_identity_audits_on_level_id"
      t.index ["user_id"], name: "index_user_identity_audits_on_user_id"
    end

    # Recreate Staff Identity Audit Tables
    create_table :staff_identity_audit_events, id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
      t.timestamps
    end

    create_table :staff_identity_audit_levels, id: :string, default: "NONE", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table :staff_identity_audits, id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
      t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
      t.string "actor_type", default: "", null: false
      t.datetime "created_at", null: false
      t.string "event_id", limit: 255, default: "", null: false
      t.string "ip_address", default: "", null: false
      t.string "level_id", default: "NONE", null: false
      t.string "subject_id"
      t.string "subject_type", default: "", null: false
      t.text "previous_value"
      t.uuid "staff_id", null: false
      t.datetime "timestamp", null: false
      t.datetime "updated_at", null: false
      t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
      t.index ["level_id"], name: "index_staff_identity_audits_on_level_id"
      t.index ["staff_id"], name: "index_staff_identity_audits_on_staff_id"
    end

    # Add foreign keys (if referenced tables exist)
    # Using if_exists checks implicitly by just running FK adds.
    # Note: Dependent migrations add constraints, so we just restore base structure.
  end
end
