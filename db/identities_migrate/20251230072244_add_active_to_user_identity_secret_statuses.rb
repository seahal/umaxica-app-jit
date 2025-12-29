# frozen_string_literal: true

class AddActiveToUserIdentitySecretStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO user_identity_secret_statuses (id)
        VALUES ('ACTIVE')
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    execute "DELETE FROM user_identity_secret_statuses WHERE id = 'ACTIVE';"
  end
end
