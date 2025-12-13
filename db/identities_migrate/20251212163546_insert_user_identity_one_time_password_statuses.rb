class InsertUserIdentityOneTimePasswordStatuses < ActiveRecord::Migration[8.2]
  def up
    execute <<-SQL.squish
      INSERT INTO user_identity_one_time_password_statuses (id, created_at, updated_at)
      VALUES
        ('ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('INACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('REVOKED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
        ('DELETED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (id) DO NOTHING;
    SQL
  end

  def down
    execute <<-SQL.squish
      DELETE FROM user_identity_one_time_password_statuses
      WHERE id IN ('ACTIVE', 'INACTIVE', 'REVOKED', 'DELETED');
    SQL
  end
end
