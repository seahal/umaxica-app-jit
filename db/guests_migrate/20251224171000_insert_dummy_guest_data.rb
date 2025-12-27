# frozen_string_literal: true

class InsertDummyGuestData < ActiveRecord::Migration[8.2]
  def change
    up_only do
      # Categories and Statuses
      execute("INSERT INTO app_contact_categories (id, description, created_at, updated_at) VALUES ('APPLICATION_INQUIRY', 'Application Inquiry', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO app_contact_statuses (id, description) VALUES ('NONE', 'None'), ('ACTIVE', 'Active') ON CONFLICT DO NOTHING")

      execute("INSERT INTO org_contact_categories (id, description, created_at, updated_at) VALUES ('ORGANIZATION_INQUIRY', 'Organization Inquiry', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO org_contact_statuses (id, description) VALUES ('NONE', 'None') ON CONFLICT DO NOTHING")

      execute("INSERT INTO com_contact_categories (id, description, created_at, updated_at) VALUES ('SECURITY_ISSUE', 'Security Issue', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO com_contact_statuses (id, description) VALUES ('NONE', 'None') ON CONFLICT DO NOTHING")
    end
  end
end
