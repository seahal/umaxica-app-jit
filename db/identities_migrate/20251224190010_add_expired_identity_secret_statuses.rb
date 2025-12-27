# frozen_string_literal: true

# rubocop:disable Rails/ReversibleMigration
class AddExpiredIdentitySecretStatuses < ActiveRecord::Migration[8.2]
  def up
    execute <<~SQL.squish
      INSERT INTO staff_identity_secret_statuses (id) VALUES
      ('EXPIRED')
      ON CONFLICT (id) DO NOTHING
    SQL

    execute <<~SQL.squish
      INSERT INTO user_identity_secret_statuses (id) VALUES
      ('EXPIRED')
      ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    execute <<~SQL.squish
      DELETE FROM staff_identity_secret_statuses WHERE id = 'EXPIRED'
    SQL

    execute <<~SQL.squish
      DELETE FROM user_identity_secret_statuses WHERE id = 'EXPIRED'
    SQL
  end
end
# rubocop:enable Rails/ReversibleMigration
