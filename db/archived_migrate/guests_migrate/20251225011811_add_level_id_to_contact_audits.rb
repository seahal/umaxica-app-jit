# frozen_string_literal: true

class AddLevelIdToContactAudits < ActiveRecord::Migration[8.2]
  def change
    add_column(:app_contact_histories, :level_id, :string, null: false, default: "NONE")
    add_column(:com_contact_audits, :level_id, :string, null: false, default: "NONE")
    add_column(:org_contact_histories, :level_id, :string, null: false, default: "NONE")

    safety_assured { add_index(:app_contact_histories, :level_id) }
    safety_assured { add_index(:com_contact_audits, :level_id) }
    safety_assured { add_index(:org_contact_histories, :level_id) }
  end
end
