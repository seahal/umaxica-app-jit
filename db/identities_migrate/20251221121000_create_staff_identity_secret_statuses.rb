# frozen_string_literal: true

# rubocop:disable Rails/CreateTableWithTimestamps
class CreateStaffIdentitySecretStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :staff_identity_secret_statuses, id: :string, limit: 255, primary_key: :id

    execute <<~SQL.squish
      INSERT INTO staff_identity_secret_statuses (id) VALUES
      ('ACTIVE'),
      ('USED'),
      ('REVOKED'),
      ('DELETED')
      ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    drop_table :staff_identity_secret_statuses
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
