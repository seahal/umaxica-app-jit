# frozen_string_literal: true

class AddNeyoToUserIdentityStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO user_identity_statuses (id)
        VALUES ('NEYO')
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    execute "DELETE FROM user_identity_statuses WHERE id = 'NEYO';"
  end
end
