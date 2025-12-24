class AddMissingIndexesToGuests < ActiveRecord::Migration[8.2]
  def change
    # Polymorphic Actor Indexes
    add_index :app_contact_histories, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :com_contact_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :org_contact_histories, [ :actor_type, :actor_id ], if_not_exists: true

    # Parent IDs for History/Categories
    add_index :app_contact_histories, :parent_id, if_not_exists: true
    add_index :org_contact_histories, :parent_id, if_not_exists: true

    add_index :app_contact_categories, :parent_id, if_not_exists: true
    add_index :com_contact_categories, :parent_id, if_not_exists: true
    add_index :org_contact_categories, :parent_id, if_not_exists: true

    # Contacts (Status, Category)
    %w[app com org].each do |prefix|
      table_name = :"#{prefix}_contacts"
      add_index table_name, :contact_status_id, if_not_exists: true
      add_index table_name, :contact_category_title, if_not_exists: true
    end
  end
end
