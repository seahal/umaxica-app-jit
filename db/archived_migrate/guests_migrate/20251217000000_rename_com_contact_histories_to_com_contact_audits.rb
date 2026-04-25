# frozen_string_literal: true

class RenameComContactHistoriesToComContactAudits < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      rename_table(:com_contact_histories, :com_contact_audits)

      return unless index_exists?(
        :com_contact_audits, :com_contact_id,
        name: "index_com_contact_histories_on_com_contact_id",
      )

      rename_index(
        :com_contact_audits,
        "index_com_contact_histories_on_com_contact_id",
        "index_com_contact_audits_on_com_contact_id",
      )
    end
  end
end
