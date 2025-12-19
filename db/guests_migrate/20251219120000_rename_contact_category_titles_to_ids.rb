# frozen_string_literal: true

# rubocop:disable Rails/DangerousColumnNames
class RenameContactCategoryTitlesToIds < ActiveRecord::Migration[8.1]
  def change
    rename_column :com_contact_categories, :title, :id
    rename_column :app_contact_categories, :title, :id
    rename_column :org_contact_categories, :title, :id

    rename_column :com_contact_categories, :parent_title, :parent_id
    rename_column :app_contact_categories, :parent_title, :parent_id
    rename_column :org_contact_categories, :parent_title, :parent_id

    rename_column :com_contact_statuses, :parent_title, :parent_id
    rename_column :org_contact_statuses, :parent_title, :parent_id
  end
end
# rubocop:enable Rails/DangerousColumnNames
