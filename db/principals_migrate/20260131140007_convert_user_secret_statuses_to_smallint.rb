class ConvertUserSecretStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      add_column :user_secret_statuses, :id_small, :integer, limit: 2

      execute("INSERT INTO user_secret_statuses (id) VALUES ('ACTIVE') ON CONFLICT DO NOTHING")
      execute("UPDATE user_secret_statuses SET id_small = 1 WHERE id = 'ACTIVE'")
      execute("UPDATE user_secret_statuses SET id_small = 0 WHERE id IN ('NEYO', '')")
      execute <<~SQL.squish
        WITH numbered AS (
          SELECT id, ROW_NUMBER() OVER (ORDER BY id) + 1 AS rn
          FROM user_secret_statuses
          WHERE id_small IS NULL
        )
        UPDATE user_secret_statuses SET id_small = numbered.rn
        FROM numbered WHERE user_secret_statuses.id = numbered.id
      SQL

      change_column_null :user_secret_statuses, :id_small, false, 0

      remove_index :user_secret_statuses, name: "index_user_identity_secret_statuses_on_lower_id"
      execute "ALTER TABLE user_secret_statuses DROP CONSTRAINT IF EXISTS chk_user_identity_secret_statuses_id_format"
      execute "ALTER TABLE user_secret_statuses DROP CONSTRAINT user_secret_statuses_pkey CASCADE"

      rename_column :user_secret_statuses, :id, :id_old_string
      rename_column :user_secret_statuses, :id_small, :id
      execute "ALTER TABLE user_secret_statuses ADD PRIMARY KEY (id)"
      add_check_constraint :user_secret_statuses, "id >= 0", name: "user_secret_statuses_id_non_negative"

      add_column :user_secrets, :user_identity_secret_status_id_small, :integer, limit: 2, default: 1
      execute <<~SQL.squish
        UPDATE user_secrets s SET user_identity_secret_status_id_small = st.id
        FROM user_secret_statuses st WHERE s.user_identity_secret_status_id = st.id_old_string
      SQL

      remove_index :user_secrets, name: "index_user_secrets_on_user_identity_secret_status_id"
      execute "ALTER TABLE user_secrets DROP CONSTRAINT IF EXISTS chk_user_identity_secrets_user_identity_secret_status_id_format"
      remove_column :user_secrets, :user_identity_secret_status_id
      rename_column :user_secrets, :user_identity_secret_status_id_small, :user_identity_secret_status_id
      change_column_null :user_secrets, :user_identity_secret_status_id, false
      change_column_default :user_secrets, :user_identity_secret_status_id, from: 1, to: 1

      add_foreign_key :user_secrets, :user_secret_statuses, column: :user_identity_secret_status_id
      add_index :user_secrets, :user_identity_secret_status_id
      add_check_constraint :user_secrets, "user_identity_secret_status_id >= 0", name: "user_secrets_user_identity_secret_status_id_non_negative"

      remove_column :user_secret_statuses, :id_old_string
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
