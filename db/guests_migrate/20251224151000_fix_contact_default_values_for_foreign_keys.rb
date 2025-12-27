# frozen_string_literal: true

class FixContactDefaultValuesForForeignKeys < ActiveRecord::Migration[8.2]
  def change
    # Change default values for status_id to 'NONE' (valid foreign key)
    %w(app_contacts com_contacts org_contacts).each do |table|
      reversible do |dir|
        dir.up do
          # Update existing empty strings to 'NONE'
          execute "UPDATE #{table} SET contact_status_id = 'NONE' WHERE contact_status_id = ''"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_default :contact_status_id, from: '', to: 'NONE'
      end
    end

    # For category_title, we'll use the first available category for each type
    # app: APPLICATION_INQUIRY, com: SECURITY_ISSUE, org: ORGANIZATION_INQUIRY
    reversible do |dir|
      dir.up do
        execute "UPDATE app_contacts SET contact_category_title = 'APPLICATION_INQUIRY' WHERE contact_category_title = ''"
        execute "UPDATE com_contacts SET contact_category_title = 'SECURITY_ISSUE' WHERE contact_category_title = ''"
        execute "UPDATE org_contacts SET contact_category_title = 'ORGANIZATION_INQUIRY' WHERE contact_category_title = ''"
      end
    end

    change_table :app_contacts, bulk: true do |t|
      t.change_default :contact_category_title, from: '', to: 'APPLICATION_INQUIRY'
    end

    change_table :com_contacts, bulk: true do |t|
      t.change_default :contact_category_title, from: '', to: 'SECURITY_ISSUE'
    end

    change_table :org_contacts, bulk: true do |t|
      t.change_default :contact_category_title, from: '', to: 'ORGANIZATION_INQUIRY'
    end
  end
end
