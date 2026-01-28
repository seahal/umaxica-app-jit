# frozen_string_literal: true

class RemoveNotNullFromContactStatusParentId < ActiveRecord::Migration[8.2]
  def change
    # Remove NOT NULL from status parent_id columns
    change_column_null :app_contact_statuses, :parent_title, true
    change_column_null :com_contact_statuses, :parent_id, true
    change_column_null :org_contact_statuses, :parent_id, true

    # Remove NOT NULL from contact status_id columns
    change_column_null :app_contacts, :status_id, true
    change_column_null :com_contacts, :status_id, true
    change_column_null :org_contacts, :status_id, true
  end
end
