# frozen_string_literal: true

class RedefineStaffSecretKindsAsLifetime < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Insert new lifetime-based kinds (UNLIMITED, ONE_TIME, TIME_BOUND)
      execute <<~SQL.squish
        INSERT INTO staff_secret_kinds (id) VALUES
          ('UNLIMITED'), ('ONE_TIME'), ('TIME_BOUND')
        ON CONFLICT (id) DO NOTHING
      SQL

      # 2. Migrate all existing staff_secrets to UNLIMITED kind
      #    This includes secrets with old kinds (LOGIN/TOTP) and any NULL values
      execute <<~SQL.squish
        UPDATE staff_secrets
        SET staff_secret_kind_id = 'UNLIMITED'
        WHERE staff_secret_kind_id IS NULL
           OR staff_secret_kind_id NOT IN ('UNLIMITED', 'ONE_TIME', 'TIME_BOUND')
      SQL

      # 3. Delete old kinds that are no longer part of the canonical set
      #    This is safe now because all staff_secrets have been migrated to UNLIMITED
      execute <<~SQL.squish
        DELETE FROM staff_secret_kinds
        WHERE id NOT IN ('UNLIMITED', 'ONE_TIME', 'TIME_BOUND')
      SQL
    end
  end

  def down
    # This migration is irreversible because:
    # - We cannot reliably restore which old kind (LOGIN/TOTP) each secret had
    # - The business logic has fundamentally changed from purpose-based to lifetime-based kinds
    raise ActiveRecord::IrreversibleMigration
  end
end
