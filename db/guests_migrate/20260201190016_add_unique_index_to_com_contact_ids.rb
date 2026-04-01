# frozen_string_literal: true

class AddUniqueIndexToComContactIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  INDEX_OPTIONS = { unique: true, algorithm: :concurrently }.freeze

  def up
    remove_index(:com_contact_emails, column: :com_contact_id, if_exists: true)
    add_unique_index(:com_contact_emails, :com_contact_id, name: "index_com_contact_emails_on_com_contact_id")

    remove_index(:com_contact_telephones, column: :com_contact_id, if_exists: true)
    add_unique_index(:com_contact_telephones, :com_contact_id, name: "index_com_contact_telephones_on_com_contact_id")
  end

  def down
    remove_index(:com_contact_emails, name: "index_com_contact_emails_on_com_contact_id", if_exists: true)
    remove_index(:com_contact_telephones, name: "index_com_contact_telephones_on_com_contact_id", if_exists: true)
  end

  private

  def add_unique_index(table, column, name:)
    add_index(table, column, **INDEX_OPTIONS.merge(name: name))
  end
end
