# rubocop:disable Rails/CreateTableWithTimestamps
class CreateUserIdentityPasskeyStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :user_identity_passkey_statuses, id: :string, limit: 255, primary_key: :id

    # Insert default status records
    execute <<~SQL.squish
      INSERT INTO user_identity_passkey_statuses (id) VALUES
      ('ACTIVE'),
      ('DISABLED'),
      ('DELETED')
      ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    drop_table :user_identity_passkey_statuses
  end
end

# rubocop:enable Rails/CreateTableWithTimestamps
