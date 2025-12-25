class SimplifyContactColumnNames < ActiveRecord::Migration[8.2]
  def up
    # app_contacts: Rename and change type for category
    rename_column :app_contacts, :contact_category_title, :category_title_old
    add_column :app_contacts, :category_id, :string, limit: 255
    execute "UPDATE app_contacts SET category_id = category_title_old"
    change_table :app_contacts, bulk: true do |t|
      t.change_null :category_id, false
      t.change_default :category_id, "NONE"
    end
    add_index :app_contacts, :category_id

    # app_contacts: Rename status
    rename_column :app_contacts, :contact_status_id, :status_id

    # com_contacts: Rename and change type for category
    rename_column :com_contacts, :contact_category_title, :category_title_old
    add_column :com_contacts, :category_id, :string, limit: 255
    execute "UPDATE com_contacts SET category_id = category_title_old"
    change_table :com_contacts, bulk: true do |t|
      t.change_null :category_id, false
      t.change_default :category_id, "NONE"
    end
    add_index :com_contacts, :category_id

    # com_contacts: Rename status
    rename_column :com_contacts, :contact_status_id, :status_id

    # org_contacts: Rename and change type for category
    rename_column :org_contacts, :contact_category_title, :category_title_old
    add_column :org_contacts, :category_id, :string, limit: 255
    execute "UPDATE org_contacts SET category_id = category_title_old"
    change_table :org_contacts, bulk: true do |t|
      t.change_null :category_id, false
      t.change_default :category_id, "NONE"
    end
    add_index :org_contacts, :category_id

    # org_contacts: Rename status
    rename_column :org_contacts, :contact_status_id, :status_id

    # Add foreign keys
    add_foreign_key :app_contacts, :app_contact_categories, column: :category_id
    add_foreign_key :app_contacts, :app_contact_statuses, column: :status_id

    add_foreign_key :com_contacts, :com_contact_categories, column: :category_id
    add_foreign_key :com_contacts, :com_contact_statuses, column: :status_id

    add_foreign_key :org_contacts, :org_contact_categories, column: :category_id
    add_foreign_key :org_contacts, :org_contact_statuses, column: :status_id

    # Remove old columns
    remove_column :app_contacts, :category_title_old
    remove_column :com_contacts, :category_title_old
    remove_column :org_contacts, :category_title_old
  end

  def down
    # Reverse the changes
    remove_foreign_key :app_contacts, column: :category_id
    remove_foreign_key :app_contacts, column: :status_id
    remove_foreign_key :com_contacts, column: :category_id
    remove_foreign_key :com_contacts, column: :status_id
    remove_foreign_key :org_contacts, column: :category_id
    remove_foreign_key :org_contacts, column: :status_id

    rename_column :app_contacts, :status_id, :contact_status_id
    add_column :app_contacts, :contact_category_title, :string, limit: 255
    execute "UPDATE app_contacts SET contact_category_title = category_id"
    remove_column :app_contacts, :category_id

    rename_column :com_contacts, :status_id, :contact_status_id
    add_column :com_contacts, :contact_category_title, :string, limit: 255
    execute "UPDATE com_contacts SET contact_category_title = category_id"
    remove_column :com_contacts, :category_id

    rename_column :org_contacts, :status_id, :contact_status_id
    add_column :org_contacts, :contact_category_title, :string, limit: 255
    execute "UPDATE org_contacts SET contact_category_title = category_id"
    remove_column :org_contacts, :category_id
  end
end
