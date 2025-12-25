class CreateUniversalAuditTables < ActiveRecord::Migration[8.2]
  def change
    # Helper method to create audit table with standard structure
    def create_audit_table(table_name, event_table_name, level_table_name)
      create_table table_name, id: :uuid, default: -> { "uuidv7()" } do |t|
        # Subject reference (DB-agnostic polymorphic pattern)
        t.string :subject_id, null: false
        t.text :subject_type, null: false

        # Actor reference (polymorphic)
        t.uuid :actor_id, null: false, default: "00000000-0000-0000-0000-000000000000"
        t.text :actor_type, null: false, default: ""

        # Event/Level references
        t.string :event_id, limit: 255, null: false, default: "NONE"
        t.string :level_id, limit: 255, null: false, default: "NONE"

        # Audit metadata
        t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
        t.datetime :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + interval '7 years'" }
        t.inet :ip_address, default: "0.0.0.0", null: false
        t.jsonb :context, null: false, default: {}

        # Data preservation
        t.text :previous_value, null: false, default: ""
        t.text :current_value, null: false, default: ""

        t.timestamps
      end

      # Indexes
      add_index table_name, :occurred_at
      add_index table_name, :expires_at
      add_index table_name, [ :subject_type, :subject_id, :occurred_at ]
      add_index table_name, [ :actor_id, :occurred_at ]
      add_index table_name, :event_id
      add_index table_name, :level_id

      # Event table
      create_table event_table_name, id: :string, limit: 255 do |t|
        t.timestamps
      end
      set_default_and_seed(event_table_name)

      # Level table
      create_table level_table_name, id: :string, limit: 255 do |t|
        t.timestamps
      end
      set_default_and_seed(level_table_name)

      # Foreign keys
      add_foreign_key table_name, event_table_name, column: :event_id
      add_foreign_key table_name, level_table_name, column: :level_id
    end

    # User Identity Audits
    create_audit_table :user_identity_audits, :user_identity_audit_events, :user_identity_audit_levels

    # Staff Identity Audits
    create_audit_table :staff_identity_audits, :staff_identity_audit_events, :staff_identity_audit_levels

    # App Document Audits
    create_audit_table :app_document_audits, :app_document_audit_events, :app_document_audit_levels

    # App Timeline Audits
    create_audit_table :app_timeline_audits, :app_timeline_audit_events, :app_timeline_audit_levels

    # App Contact Audits (using app_contact_histories for backward compatibility)
    create_table :app_contact_histories, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :subject_id, null: false
      t.text :subject_type, null: false
      t.uuid :actor_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.text :actor_type, null: false, default: ""
      t.string :event_id, limit: 255, null: false, default: "NONE"
      t.string :level_id, limit: 255, null: false, default: "NONE"
      t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + interval '7 years'" }
      t.inet :ip_address, default: "0.0.0.0", null: false
      t.jsonb :context, null: false, default: {}
      t.text :previous_value, null: false, default: ""
      t.text :current_value, null: false, default: ""
      t.uuid :parent_id, default: "00000000-0000-0000-0000-000000000000", null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :app_contact_histories, :occurred_at
    add_index :app_contact_histories, :expires_at
    add_index :app_contact_histories, [ :subject_type, :subject_id, :occurred_at ]
    add_index :app_contact_histories, [ :actor_id, :occurred_at ]
    add_index :app_contact_histories, :event_id
    add_index :app_contact_histories, :level_id
    add_index :app_contact_histories, :parent_id

    create_table :app_contact_audit_events, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:app_contact_audit_events)

    create_table :app_contact_audit_levels, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:app_contact_audit_levels)

    add_foreign_key :app_contact_histories, :app_contact_audit_events, column: :event_id
    add_foreign_key :app_contact_histories, :app_contact_audit_levels, column: :level_id

    # Com Document Audits
    create_audit_table :com_document_audits, :com_document_audit_events, :com_document_audit_levels

    # Com Timeline Audits
    create_audit_table :com_timeline_audits, :com_timeline_audit_events, :com_timeline_audit_levels

    # Com Contact Audits
    create_table :com_contact_audits, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :subject_id, null: false
      t.text :subject_type, null: false
      t.uuid :actor_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.text :actor_type, null: false, default: ""
      t.string :event_id, limit: 255, null: false, default: "NONE"
      t.string :level_id, limit: 255, null: false, default: "NONE"
      t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + interval '7 years'" }
      t.inet :ip_address, default: "0.0.0.0", null: false
      t.jsonb :context, null: false, default: {}
      t.text :previous_value, null: false, default: ""
      t.text :current_value, null: false, default: ""
      t.uuid :parent_id, default: "00000000-0000-0000-0000-000000000000", null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :com_contact_audits, :occurred_at
    add_index :com_contact_audits, :expires_at
    add_index :com_contact_audits, [ :subject_type, :subject_id, :occurred_at ]
    add_index :com_contact_audits, [ :actor_id, :occurred_at ]
    add_index :com_contact_audits, :event_id
    add_index :com_contact_audits, :level_id
    add_index :com_contact_audits, :parent_id

    create_table :com_contact_audit_events, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:com_contact_audit_events)

    create_table :com_contact_audit_levels, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:com_contact_audit_levels)

    add_foreign_key :com_contact_audits, :com_contact_audit_events, column: :event_id
    add_foreign_key :com_contact_audits, :com_contact_audit_levels, column: :level_id

    # Org Document Audits
    create_audit_table :org_document_audits, :org_document_audit_events, :org_document_audit_levels

    # Org Timeline Audits
    create_audit_table :org_timeline_audits, :org_timeline_audit_events, :org_timeline_audit_levels

    # Org Contact Audits (using org_contact_histories for backward compatibility)
    create_table :org_contact_histories, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :subject_id, null: false
      t.text :subject_type, null: false
      t.uuid :actor_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.text :actor_type, null: false, default: ""
      t.string :event_id, limit: 255, null: false, default: "NONE"
      t.string :level_id, limit: 255, null: false, default: "NONE"
      t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + interval '7 years'" }
      t.inet :ip_address, default: "0.0.0.0", null: false
      t.jsonb :context, null: false, default: {}
      t.text :previous_value, null: false, default: ""
      t.text :current_value, null: false, default: ""
      t.uuid :parent_id, default: "00000000-0000-0000-0000-000000000000", null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :org_contact_histories, :occurred_at
    add_index :org_contact_histories, :expires_at
    add_index :org_contact_histories, [ :subject_type, :subject_id, :occurred_at ]
    add_index :org_contact_histories, [ :actor_id, :occurred_at ]
    add_index :org_contact_histories, :event_id
    add_index :org_contact_histories, :level_id
    add_index :org_contact_histories, :parent_id

    create_table :org_contact_audit_events, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:org_contact_audit_events)

    create_table :org_contact_audit_levels, id: :string, limit: 255 do |t|
      t.timestamps
    end
    set_default_and_seed(:org_contact_audit_levels)

    add_foreign_key :org_contact_histories, :org_contact_audit_events, column: :event_id
    add_foreign_key :org_contact_histories, :org_contact_audit_levels, column: :level_id
  end

  def set_default_and_seed(table_name)
    reversible do |dir|
      dir.up do
        execute "ALTER TABLE #{table_name} ALTER COLUMN id SET DEFAULT 'NONE'"
        execute "INSERT INTO #{table_name} (id, created_at, updated_at) VALUES ('NONE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
      end
      dir.down do
        execute "DELETE FROM #{table_name} WHERE id = 'NONE'"
        execute "ALTER TABLE #{table_name} ALTER COLUMN id DROP DEFAULT"
      end
    end
  end
end
