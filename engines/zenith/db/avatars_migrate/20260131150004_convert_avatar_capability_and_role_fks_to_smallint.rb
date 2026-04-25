# typed: false
# frozen_string_literal: true

class ConvertAvatarCapabilityAndRoleFksToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Convert avatars.capability_id
      convert_capability_id

      # 2. Convert avatar_memberships.role_id
      convert_role_id
    end
  end

  def convert_capability_id
    # 1. Add new FK column
    add_column(:avatars, :capability_id_small, :integer, limit: 2, default: 0)

    # 2. Backfill: Join with avatar_capabilities on old string id
    execute(<<~SQL.squish)
      UPDATE avatars a
      SET capability_id_small = c.id
      FROM avatar_capabilities c
      WHERE a.capability_id = c.id_old_string
    SQL

    # 3. Remove old index
    remove_index(:avatars, :capability_id, if_exists: true)

    # 4. Drop old column
    remove_column(:avatars, :capability_id)

    # 5. Rename new column
    rename_column(:avatars, :capability_id_small, :capability_id)

    # 6. Set NOT NULL (capability_id is required)
    change_column_null(:avatars, :capability_id, false)

    # 7. Set default
    change_column_default(:avatars, :capability_id, from: 0, to: 0)

    # 8. Add FK constraint
    add_foreign_key(:avatars, :avatar_capabilities, column: :capability_id)

    # 9. Add index
    add_index(:avatars, :capability_id)

    # 10. Add CHECK constraint
    execute("ALTER TABLE avatars ADD CONSTRAINT chk_avatars_capability_id_positive CHECK (capability_id >= 0)")
  end

  def convert_role_id
    # 1. Add new FK column
    add_column(:avatar_memberships, :role_id_small, :integer, limit: 2, default: 0)

    # 2. Backfill: Join with avatar_roles on old string id
    execute(<<~SQL.squish)
      UPDATE avatar_memberships am
      SET role_id_small = r.id
      FROM avatar_roles r
      WHERE am.role_id = r.id_old_string
    SQL

    # 3. Drop old column (no index on this one based on schema)
    remove_column(:avatar_memberships, :role_id)

    # 4. Rename new column
    rename_column(:avatar_memberships, :role_id_small, :role_id)

    # 5. Set NOT NULL (role_id is required)
    change_column_null(:avatar_memberships, :role_id, false)

    # 6. Set default
    change_column_default(:avatar_memberships, :role_id, from: 0, to: 0)

    # 7. Add FK constraint
    add_foreign_key(:avatar_memberships, :avatar_roles, column: :role_id)

    # 8. Add CHECK constraint
    execute("ALTER TABLE avatar_memberships ADD CONSTRAINT chk_avatar_memberships_role_id_positive CHECK (role_id >= 0)")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
