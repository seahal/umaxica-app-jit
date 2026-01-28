# frozen_string_literal: true

class RedefineUserSecretKindsAsLifetime < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Insert new lifetime-based kinds (UNLIMITED, ONE_TIME, TIME_BOUND)
      execute <<~SQL.squish
        INSERT INTO user_secret_kinds (id) VALUES
          ('UNLIMITED'), ('ONE_TIME'), ('TIME_BOUND')
        ON CONFLICT (id) DO NOTHING
      SQL

      # 2. Migrate all existing user_secrets to UNLIMITED kind
      #    This includes secrets with old kinds (LOGIN/TOTP/RECOVERY/API) and any NULL values
      execute <<~SQL.squish
        UPDATE user_secrets
        SET user_secret_kind_id = 'UNLIMITED'
        WHERE user_secret_kind_id IS NULL
           OR user_secret_kind_id NOT IN ('UNLIMITED', 'ONE_TIME', 'TIME_BOUND')
      SQL

      # 3. Delete old kinds that are no longer part of the canonical set
      #    This is safe now because all user_secrets have been migrated to UNLIMITED
      execute <<~SQL.squish
        DELETE FROM user_secret_kinds
        WHERE id NOT IN ('UNLIMITED', 'ONE_TIME', 'TIME_BOUND')
      SQL
    end
  end

  def down
    # This migration is irreversible because:
    # - We cannot reliably restore which old kind (LOGIN/TOTP/RECOVERY/API) each secret had
    # - The business logic has fundamentally changed from purpose-based to lifetime-based kinds
    raise ActiveRecord::IrreversibleMigration
  end
end
