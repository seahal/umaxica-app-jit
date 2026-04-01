# frozen_string_literal: true

class AddUniqueIndexesForComContactHasOne < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # com_contact_emails.com_contact_id should be unique for has_one
      unless index_exists?(:com_contact_emails, :com_contact_id, unique: true)
        # Remove non-unique index first if exists
        if index_exists?(:com_contact_emails, :com_contact_id)
          remove_index(:com_contact_emails, :com_contact_id, algorithm: :concurrently)
        end
        add_index(
          :com_contact_emails, :com_contact_id, unique: true,
                                                name: "index_com_contact_emails_on_com_contact_id_unique",
                                                algorithm: :concurrently,
        )
      end

      # com_contact_telephones.com_contact_id should be unique for has_one
      unless index_exists?(:com_contact_telephones, :com_contact_id, unique: true)
        # Remove non-unique index first if exists
        if index_exists?(:com_contact_telephones, :com_contact_id)
          remove_index(:com_contact_telephones, :com_contact_id, algorithm: :concurrently)
        end
        add_index(
          :com_contact_telephones, :com_contact_id, unique: true,
                                                    name: "index_com_contact_telephones_on_com_contact_id_unique",
                                                    algorithm: :concurrently,
        )
      end
    end
  end

  def down
    remove_index(:com_contact_emails, name: "index_com_contact_emails_on_com_contact_id_unique") if index_exists?(
      :com_contact_emails, nil, name: "index_com_contact_emails_on_com_contact_id_unique",
    )
    remove_index(
      :com_contact_telephones,
      name: "index_com_contact_telephones_on_com_contact_id_unique",
    ) if index_exists?(
      :com_contact_telephones, nil, name: "index_com_contact_telephones_on_com_contact_id_unique",
    )
  end
end
