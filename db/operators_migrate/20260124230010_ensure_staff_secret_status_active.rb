# frozen_string_literal: true

class EnsureStaffSecretStatusActive < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO staff_secret_statuses (id)
        VALUES ('ACTIVE')
        ON CONFLICT (id) DO NOTHING
      SQL

      execute <<~SQL.squish
        UPDATE staff_secrets
        SET staff_identity_secret_status_id = 'ACTIVE'
        WHERE staff_identity_secret_status_id IS NULL
           OR NOT EXISTS (
             SELECT 1
             FROM staff_secret_statuses
             WHERE staff_secret_statuses.id = staff_secrets.staff_identity_secret_status_id
           )
      SQL
    end
  end

  def down
    # No-op: keep seeded reference data in place.
  end
end
