# frozen_string_literal: true

class AddNeyoToOrgContactCategories < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO org_contact_categories (id, description, active, parent_id, position, created_at, updated_at)
        VALUES ('NEYO', 'Default Category', true, '', 0, NOW(), NOW())
        ON CONFLICT (id) DO NOTHING;
      SQL
    end
  end

  def down
    execute "DELETE FROM org_contact_categories WHERE id = 'NEYO';"
  end
end
