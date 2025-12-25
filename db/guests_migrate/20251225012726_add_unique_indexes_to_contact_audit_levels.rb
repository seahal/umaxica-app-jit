class AddUniqueIndexesToContactAuditLevels < ActiveRecord::Migration[8.2]
  def change
    add_index :app_contact_audit_levels, "lower(id)", unique: true, name: "index_app_contact_audit_levels_on_lower_id"
    add_index :com_contact_audit_levels, "lower(id)", unique: true, name: "index_com_contact_audit_levels_on_lower_id"
    add_index :org_contact_audit_levels, "lower(id)", unique: true, name: "index_org_contact_audit_levels_on_lower_id"
  end
end
