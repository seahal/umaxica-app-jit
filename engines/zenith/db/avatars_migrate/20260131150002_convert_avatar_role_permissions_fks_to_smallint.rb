# typed: false
# frozen_string_literal: true

class ConvertAvatarRolePermissionsFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add new FK columns
      add_column(:avatar_role_permissions, :avatar_role_id_small, :integer, limit: 2, default: 0)
      add_column(:avatar_role_permissions, :avatar_permission_id_small, :integer, limit: 2, default: 0)

      # 2. Backfill avatar_role_id
      execute(<<~SQL.squish)
        UPDATE avatar_role_permissions arp
        SET avatar_role_id_small = r.id
        FROM avatar_roles r
        WHERE arp.avatar_role_id = r.id_old_string
      SQL

      # 3. Backfill avatar_permission_id
      execute(<<~SQL.squish)
        UPDATE avatar_role_permissions arp
        SET avatar_permission_id_small = p.id
        FROM avatar_permissions p
        WHERE arp.avatar_permission_id = p.id_old_string
      SQL

      # 4. Remove old indexes and constraints
      remove_index(:avatar_role_permissions, :avatar_role_id, if_exists: true)
      remove_index(:avatar_role_permissions, :avatar_permission_id, if_exists: true)
      remove_index(:avatar_role_permissions, name: "uniq_avatar_role_permissions", if_exists: true)

      # 5. Drop old columns
      remove_column(:avatar_role_permissions, :avatar_role_id)
      remove_column(:avatar_role_permissions, :avatar_permission_id)

      # 6. Rename new columns
      rename_column(:avatar_role_permissions, :avatar_role_id_small, :avatar_role_id)
      rename_column(:avatar_role_permissions, :avatar_permission_id_small, :avatar_permission_id)

      # 7. Set NOT NULL
      change_column_null(:avatar_role_permissions, :avatar_role_id, false)
      change_column_null(:avatar_role_permissions, :avatar_permission_id, false)

      # 8. Set default to 0
      change_column_default(:avatar_role_permissions, :avatar_role_id, from: 0, to: 0)
      change_column_default(:avatar_role_permissions, :avatar_permission_id, from: 0, to: 0)

      # 9. Add FKs
      add_foreign_key(:avatar_role_permissions, :avatar_roles)
      add_foreign_key(:avatar_role_permissions, :avatar_permissions)

      # 10. Add indexes
      add_index(:avatar_role_permissions, :avatar_role_id)
      add_index(:avatar_role_permissions, :avatar_permission_id)
      add_index(
        :avatar_role_permissions, [:avatar_role_id, :avatar_permission_id],
        unique: true, name: "uniq_avatar_role_permissions",
      )

      # 11. Add CHECK constraints
      execute("ALTER TABLE avatar_role_permissions ADD CONSTRAINT chk_avatar_role_permissions_role_id_positive CHECK (avatar_role_id >= 0)")
      execute("ALTER TABLE avatar_role_permissions ADD CONSTRAINT chk_avatar_role_permissions_permission_id_positive CHECK (avatar_permission_id >= 0)")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
