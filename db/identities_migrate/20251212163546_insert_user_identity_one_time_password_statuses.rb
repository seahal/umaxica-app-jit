# frozen_string_literal: true

class InsertUserIdentityOneTimePasswordStatuses < ActiveRecord::Migration[8.2]
  def up
    execute <<-SQL.squish
      INSERT INTO user_identity_one_time_password_statuses (id)
      VALUES
        ('ACTIVE'),
        ('INACTIVE'),
        ('REVOKED'),
        ('DELETED')
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
