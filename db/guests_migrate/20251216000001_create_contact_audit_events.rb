# rubocop:disable Rails/CreateTableWithTimestamps
class CreateContactAuditEvents < ActiveRecord::Migration[8.2]
  def change
    # Create Event Tables
    create_table :com_contact_audit_events, id: :string, limit: 255
    create_table :app_contact_audit_events, id: :string, limit: 255
    create_table :org_contact_audit_events, id: :string, limit: 255

    # Insert default records to satisfy FK constraints
    reversible do |dir|
      dir.up do
        execute "INSERT INTO com_contact_audit_events (id) VALUES ('NONE')"
        execute "INSERT INTO app_contact_audit_events (id) VALUES ('NONE')"
        execute "INSERT INTO org_contact_audit_events (id) VALUES ('NONE')"
      end
    end

    # Add event_id to History Tables
    add_column :com_contact_histories, :event_id, :string, limit: 255, null: false, default: "NONE"
    add_column :app_contact_histories, :event_id, :string, limit: 255, null: false, default: "NONE"
    add_column :org_contact_histories, :event_id, :string, limit: 255, null: false, default: "NONE"

    # Add Foreign Keys
    add_foreign_key :com_contact_histories, :com_contact_audit_events, column: :event_id
    add_foreign_key :app_contact_histories, :app_contact_audit_events, column: :event_id
    add_foreign_key :org_contact_histories, :org_contact_audit_events, column: :event_id
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
