class NullifyContactSentinels < ActiveRecord::Migration[8.2]
  def up
    execute <<~SQL.squish
      UPDATE app_contacts
      SET contact_category_title = NULL
      WHERE contact_category_title IN ('NULL_APP_CATEGORY')
    SQL

    execute <<~SQL.squish
      UPDATE app_contacts
      SET contact_status_id = NULL
      WHERE contact_status_id IN ('NULL_APP_STATUS')
    SQL

    execute <<~SQL.squish
      UPDATE org_contacts
      SET contact_category_title = NULL
      WHERE contact_category_title IN ('NULL_ORG_CATEGORY')
    SQL

    execute <<~SQL.squish
      UPDATE org_contacts
      SET contact_status_id = NULL
      WHERE contact_status_id IN ('NULL_ORG_STATUS')
    SQL

    execute "DELETE FROM app_contact_categories WHERE id = 'NULL_APP_CATEGORY'"
    execute "DELETE FROM app_contact_statuses WHERE id = 'NULL_APP_STATUS'"
    execute "DELETE FROM org_contact_categories WHERE id = 'NULL_ORG_CATEGORY'"
    execute "DELETE FROM org_contact_statuses WHERE id = 'NULL_ORG_STATUS'"
  end

  def down
    execute <<~SQL.squish
      INSERT INTO app_contact_categories
        (id, description, parent_id, position, active, created_at, updated_at)
      SELECT
        'NULL_APP_CATEGORY', 'NULL', NULL, 0, true, NOW(), NOW()
      WHERE NOT EXISTS (
        SELECT 1 FROM app_contact_categories WHERE id = 'NULL_APP_CATEGORY'
      )
    SQL

    execute <<~SQL.squish
      INSERT INTO app_contact_statuses
        (id, description, parent_title, position, active)
      SELECT
        'NULL_APP_STATUS', 'NULL', NULL, 0, true
      WHERE NOT EXISTS (
        SELECT 1 FROM app_contact_statuses WHERE id = 'NULL_APP_STATUS'
      )
    SQL

    execute <<~SQL.squish
      INSERT INTO org_contact_categories
        (id, description, parent_id, position, active, created_at, updated_at)
      SELECT
        'NULL_ORG_CATEGORY', 'NULL', NULL, 0, true, NOW(), NOW()
      WHERE NOT EXISTS (
        SELECT 1 FROM org_contact_categories WHERE id = 'NULL_ORG_CATEGORY'
      )
    SQL

    execute <<~SQL.squish
      INSERT INTO org_contact_statuses
        (id, description, parent_id, position, active)
      SELECT
        'NULL_ORG_STATUS', 'NULL', NULL, 0, true
      WHERE NOT EXISTS (
        SELECT 1 FROM org_contact_statuses WHERE id = 'NULL_ORG_STATUS'
      )
    SQL

    execute <<~SQL.squish
      UPDATE app_contacts
      SET contact_category_title = 'NULL_APP_CATEGORY'
      WHERE contact_category_title IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE app_contacts
      SET contact_status_id = 'NULL_APP_STATUS'
      WHERE contact_status_id IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE org_contacts
      SET contact_category_title = 'NULL_ORG_CATEGORY'
      WHERE contact_category_title IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE org_contacts
      SET contact_status_id = 'NULL_ORG_STATUS'
      WHERE contact_status_id IS NULL
    SQL
  end
end
