# frozen_string_literal: true

class AddLevelIdToContactAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :app_contact_histories, :level_id, :string, null: false, default: "NONE"
    add_column :com_contact_audits, :level_id, :string, null: false, default: "NONE"
    add_column :org_contact_histories, :level_id, :string, null: false, default: "NONE"

    add_index :app_contact_histories, :level_id
    add_index :com_contact_audits, :level_id
    add_index :org_contact_histories, :level_id
  end
end
