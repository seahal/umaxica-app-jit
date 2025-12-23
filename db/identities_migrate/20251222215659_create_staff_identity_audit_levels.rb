class CreateStaffIdentityAuditLevels < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_identity_audit_levels, id: :string, default: "NONE" do |t|
      t.timestamps
    end

    add_column :staff_identity_audits, :level_id, :string, default: "NONE", null: false
    add_index :staff_identity_audits, :level_id
    add_foreign_key :staff_identity_audits, :staff_identity_audit_levels, column: :level_id
  end
end
