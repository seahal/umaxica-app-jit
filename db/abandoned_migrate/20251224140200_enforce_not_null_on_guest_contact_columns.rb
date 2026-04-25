# frozen_string_literal: true

class EnforceNotNullOnGuestContactColumns < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      execute("UPDATE app_contact_topics SET title = '' WHERE title IS NULL")
      execute("UPDATE app_contact_topics SET description = '' WHERE description IS NULL")
      execute("UPDATE app_contacts SET public_id = '' WHERE public_id IS NULL")
      execute("UPDATE app_contact_topics SET public_id = '' WHERE public_id IS NULL")
      execute("UPDATE com_contacts SET public_id = '' WHERE public_id IS NULL")
      execute("UPDATE com_contact_topics SET public_id = '' WHERE public_id IS NULL")
      execute("UPDATE org_contacts SET public_id = '' WHERE public_id IS NULL")
      execute("UPDATE org_contact_topics SET public_id = '' WHERE public_id IS NULL")

      change_column_null(:app_contact_topics, :title, false)
      change_column_null(:app_contact_topics, :description, false)
      change_column_null(:app_contacts, :public_id, false)
      change_column_null(:app_contact_topics, :public_id, false)
      change_column_null(:com_contacts, :public_id, false)
      change_column_null(:com_contact_topics, :public_id, false)
      change_column_null(:org_contacts, :public_id, false)
      change_column_null(:org_contact_topics, :public_id, false)
    end
  end

  def down
    safety_assured do
      change_column_null(:org_contact_topics, :public_id, true)
      change_column_null(:org_contacts, :public_id, true)
      change_column_null(:com_contact_topics, :public_id, true)
      change_column_null(:com_contacts, :public_id, true)
      change_column_null(:app_contact_topics, :public_id, true)
      change_column_null(:app_contacts, :public_id, true)
      change_column_null(:app_contact_topics, :description, true)
      change_column_null(:app_contact_topics, :title, true)
    end
  end
end
