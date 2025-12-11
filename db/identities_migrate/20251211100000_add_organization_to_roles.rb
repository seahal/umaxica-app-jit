class AddOrganizationToRoles < ActiveRecord::Migration[8.2]
  def change
    add_column :roles, :organization_id, :uuid
    add_index :roles, :organization_id
    add_foreign_key :roles, :organizations
    change_column_null :roles, :organization_id, false
  end
end
