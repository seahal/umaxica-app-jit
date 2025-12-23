class CreateBusinessAuditLevels < ActiveRecord::Migration[8.0]
  def change
    # Org Timeline
    create_table :org_timeline_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :org_timeline_audits, :level_id, :string, default: "NONE", null: false
    add_index :org_timeline_audits, :level_id
    add_foreign_key :org_timeline_audits, :org_timeline_audit_levels, column: :level_id

    # Org Document
    create_table :org_document_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :org_document_audits, :level_id, :string, default: "NONE", null: false
    add_index :org_document_audits, :level_id
    add_foreign_key :org_document_audits, :org_document_audit_levels, column: :level_id

    # Com Timeline
    create_table :com_timeline_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :com_timeline_audits, :level_id, :string, default: "NONE", null: false
    add_index :com_timeline_audits, :level_id
    add_foreign_key :com_timeline_audits, :com_timeline_audit_levels, column: :level_id

    # Com Document
    create_table :com_document_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :com_document_audits, :level_id, :string, default: "NONE", null: false
    add_index :com_document_audits, :level_id
    add_foreign_key :com_document_audits, :com_document_audit_levels, column: :level_id

    # App Timeline
    create_table :app_timeline_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :app_timeline_audits, :level_id, :string, default: "NONE", null: false
    add_index :app_timeline_audits, :level_id
    add_foreign_key :app_timeline_audits, :app_timeline_audit_levels, column: :level_id

    # App Document
    create_table :app_document_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end
    add_column :app_document_audits, :level_id, :string, default: "NONE", null: false
    add_index :app_document_audits, :level_id
    add_foreign_key :app_document_audits, :app_document_audit_levels, column: :level_id

    # Check if we should seed here or in a separate migration?
    # The user request implied doing it similarly to UserIdentityAudit.
    # UserIdentityAudit had separate seeding, but for conciseness I'll include it or do it next.
    # Previous summary showed a seed migration: 20251222213000_seed_user_identity_audit_levels.rb
    # I'll include data insertion here to ensure FK constraints work immediately if there are existing records (though unlikely in dev/test for these specific tables if they are new, but good practice).
    # Wait, these tables are new, but audit tables might have data.
    # If audit tables have data, default "NONE" works if the "NONE" record exists.
    # So I must insert "NONE" before adding the foreign key if I want to be safe,
    # but `default: "NONE"` on column creation just sets the default value for new records (and backfills existing if Rails < 5, or regular Postgres behavior).
    # To satisfy the FK, the parent record "NONE" must exist.

    reversible do |dir|
      dir.up do
        %w[org_timeline com_timeline app_timeline org_document com_document app_document].each do |prefix|
          execute <<~SQL.squish
            INSERT INTO #{prefix}_audit_levels (id, created_at, updated_at)
            VALUES ('NONE', NOW(), NOW()), ('INFO', NOW(), NOW()), ('WARN', NOW(), NOW()), ('ERROR', NOW(), NOW())
            ON CONFLICT (id) DO NOTHING;
          SQL
        end
      end
    end
  end
end
