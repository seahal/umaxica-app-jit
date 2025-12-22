class AddLevelToUserIdentityAudits < ActiveRecord::Migration[8.2]
  def up
    add_column :user_identity_audits, :level_id, :string, limit: 255, default: "NONE"

    execute <<~SQL.squish
      INSERT INTO user_identity_audit_levels (id, created_at, updated_at)
      VALUES ('NONE', NOW(), NOW())
      ON CONFLICT (id) DO NOTHING
    SQL

    execute <<~SQL.squish
      UPDATE user_identity_audits
      SET level_id = 'NONE'
      WHERE level_id IS NULL
    SQL

    change_column_null :user_identity_audits, :level_id, false

    add_index :user_identity_audits, :level_id
    add_foreign_key :user_identity_audits, :user_identity_audit_levels, column: :level_id, primary_key: :id
  end

  def down
    remove_foreign_key :user_identity_audits, column: :level_id
    remove_index :user_identity_audits, :level_id
    remove_column :user_identity_audits, :level_id
  end
end
