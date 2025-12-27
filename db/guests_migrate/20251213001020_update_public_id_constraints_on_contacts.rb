# frozen_string_literal: true

class UpdatePublicIdConstraintsOnContacts < ActiveRecord::Migration[8.2]
  def up
    change_column :app_contacts, :public_id, :string, limit: 21, null: false
    change_column :org_contacts, :public_id, :string, limit: 21, null: false
    change_column :com_contacts, :public_id, :string, limit: 21, null: false

    add_index :app_contacts, :public_id unless index_exists?(:app_contacts, :public_id)
    add_index :org_contacts, :public_id unless index_exists?(:org_contacts, :public_id)
    add_index :com_contacts, :public_id unless index_exists?(:com_contacts, :public_id)
  end

  def down
    change_column :app_contacts, :public_id, :string, limit: 21, null: false
    change_column :org_contacts, :public_id, :string, limit: 21, null: false
    change_column :com_contacts, :public_id, :string, limit: 21, null: false
  end
end
