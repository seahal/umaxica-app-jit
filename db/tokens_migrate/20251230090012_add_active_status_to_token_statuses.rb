# frozen_string_literal: true

class AddActiveStatusToTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Insert required statuses for user_token_statuses
      execute <<~SQL.squish
        INSERT INTO user_token_statuses (id)
        VALUES ('ACTIVE'), ('NEYO')
        ON CONFLICT (id) DO NOTHING;
      SQL

      # Insert required statuses for staff_token_statuses
      execute <<~SQL.squish
        INSERT INTO staff_token_statuses (id)
        VALUES ('ACTIVE'), ('NEYO')
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    safety_assured do
      # Remove statuses (only if safe to do so)
      execute "DELETE FROM user_token_statuses WHERE id IN ('ACTIVE', 'NEYO');"
      execute "DELETE FROM staff_token_statuses WHERE id IN ('ACTIVE', 'NEYO');"
    end
  end
end
