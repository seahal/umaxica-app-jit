class RenameComContactHistoriesToComContactAudits < ActiveRecord::Migration[8.2]
  def change
    # Rename the table from com_contact_histories to com_contact_audits
    rename_table :com_contact_histories, :com_contact_audits

    # Rename the index (Rails may handle this automatically, but being explicit)
    if index_exists?(:com_contact_audits, :com_contact_id, name: "index_com_contact_histories_on_com_contact_id")
      rename_index :com_contact_audits,
                   "index_com_contact_histories_on_com_contact_id",
                   "index_com_contact_audits_on_com_contact_id"
    end
  end
end
