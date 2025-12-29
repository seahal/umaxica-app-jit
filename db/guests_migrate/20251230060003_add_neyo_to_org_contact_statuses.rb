# frozen_string_literal: true

class AddNeyoToOrgContactStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO org_contact_statuses (id, description, active, parent_id, position)
        VALUES ('NEYO', 'Default Status', true, '', 0)
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    execute "DELETE FROM org_contact_statuses WHERE id = 'NEYO';"
  end
end
