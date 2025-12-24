class AddIndexesToContactParentIds < ActiveRecord::Migration[8.2]
  def change
    add_parent_id_index :app_contact_categories
    add_parent_id_index :com_contact_statuses
    add_parent_id_index :org_contact_statuses
  end

  private

    def add_parent_id_index(table)
      return if index_exists?(table, :parent_id)

      add_index table, :parent_id
    end
end
