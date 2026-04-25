# frozen_string_literal: true

class UpdateComContactRelations < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column(:com_contact_emails, :com_contact_id, :bigint)
    add_column(:com_contact_telephones, :com_contact_id, :bigint)

    add_index(:com_contact_emails, :com_contact_id, algorithm: :concurrently)
    add_index(:com_contact_telephones, :com_contact_id, algorithm: :concurrently)

    backfill_email_contact_ids
    backfill_telephone_contact_ids

    add_check_constraint(
      :com_contact_emails, "com_contact_id IS NOT NULL",
      name: "com_contact_emails_com_contact_id_null",
      validate: false,
    )
    add_check_constraint(
      :com_contact_telephones, "com_contact_id IS NOT NULL",
      name: "com_contact_telephones_com_contact_id_null",
      validate: false,
    )

    safety_assured do
      change_table(:com_contacts, bulk: true) do |t|
        t.remove(:com_contact_email_id)
        t.remove(:com_contact_telephone_id)
      end
    end
  end

  def down
    safety_assured do
      change_table(:com_contacts, bulk: true) do |t|
        t.string(:com_contact_email_id)
        t.string(:com_contact_telephone_id)
      end
    end

    execute(<<~SQL.squish)
      UPDATE com_contacts
      SET com_contact_email_id = com_contact_emails.id::text
      FROM com_contact_emails
      WHERE com_contact_emails.com_contact_id = com_contacts.id
    SQL

    execute(<<~SQL.squish)
      UPDATE com_contacts
      SET com_contact_telephone_id = com_contact_telephones.id::text
      FROM com_contact_telephones
      WHERE com_contact_telephones.com_contact_id = com_contacts.id
    SQL

    remove_index(:com_contact_emails, :com_contact_id, algorithm: :concurrently)
    remove_index(:com_contact_telephones, :com_contact_id, algorithm: :concurrently)

    remove_column(:com_contact_emails, :com_contact_id)
    remove_column(:com_contact_telephones, :com_contact_id)
  end

  private

  def backfill_email_contact_ids
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE com_contact_emails
        SET com_contact_id = contacts.id
        FROM com_contacts contacts
        WHERE contacts.com_contact_email_id = com_contact_emails.id::text
      SQL
    end
  end

  def backfill_telephone_contact_ids
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE com_contact_telephones
        SET com_contact_id = contacts.id
        FROM com_contacts contacts
        WHERE contacts.com_contact_telephone_id = com_contact_telephones.id::text
      SQL
    end
  end
end
