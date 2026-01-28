# frozen_string_literal: true

class EnsureUserSecretStatusActive < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO user_secret_statuses (id)
        VALUES ('ACTIVE')
        ON CONFLICT (id) DO NOTHING
      SQL

      execute <<~SQL.squish
        UPDATE user_secrets
        SET user_identity_secret_status_id = 'ACTIVE'
        WHERE user_identity_secret_status_id IS NULL
           OR NOT EXISTS (
             SELECT 1
             FROM user_secret_statuses
             WHERE user_secret_statuses.id = user_secrets.user_identity_secret_status_id
           )
      SQL
    end
  end

  def down
    # No-op: keep seeded reference data in place.
  end
end
