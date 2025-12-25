class RestoreBusinessAuditTables < ActiveRecord::Migration[8.2]
  def change
    # Helper to create standard audit tables
    def create_audit_tables(prefix)
      create_table :"#{prefix}_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
        t.timestamps
      end

      create_table :"#{prefix}_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end

      create_table :"#{prefix}_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
        # References (e.g. org_document_id)
        # We use a generic approach or specific?
        # Original creation used: t.references :org_document
        # Here we can infer from prefix?
        # prefix is like "org_document"
        t.references prefix.to_sym, null: false, type: :uuid, index: true
        t.string :event_id, null: false, limit: 255
        t.datetime :timestamp
        t.string :ip_address
        t.uuid :actor_id
        t.text :previous_value
        t.text :current_value
        t.string :subject_id # Added for consistency/indexing compatibility
        t.string :subject_type, default: "", null: false
        t.string :actor_type # Added in 20251213...

        t.timestamps

        t.index [ :event_id ], name: "index_#{prefix}_audits_on_event_id"
      end
    end

    # App Documents
    create_audit_tables("app_document")
    # App Timelines
    create_audit_tables("app_timeline")

    # Com Documents
    create_audit_tables("com_document")
    # Com Timelines
    create_audit_tables("com_timeline")

    # Org Documents
    create_audit_tables("org_document")
    # Org Timelines
    create_audit_tables("org_timeline")
  end
end
