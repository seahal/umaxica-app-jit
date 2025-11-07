class InvertCorporateSiteContactDependencies < ActiveRecord::Migration[8.1]
  def up
    add_reference :corporate_site_contacts,
                  :corporate_site_contact_email,
                  type: :uuid,
                  index: { name: "idx_on_corporate_site_contact_email_id" },
                  foreign_key: { to_table: :corporate_site_contact_emails }

    add_reference :corporate_site_contacts,
                  :corporate_site_contact_telephone,
                  type: :uuid,
                  index: { name: "idx_on_corporate_site_contact_telephone_id" },
                  foreign_key: { to_table: :corporate_site_contact_telephones }

    contact_class = Class.new(ActiveRecord::Base) do
      self.table_name = "corporate_site_contacts"
    end

    email_class = Class.new(ActiveRecord::Base) do
      self.table_name = "corporate_site_contact_emails"
    end

    telephone_class = Class.new(ActiveRecord::Base) do
      self.table_name = "corporate_site_contact_telephones"
    end

    say_with_time "Backfilling corporate_site_contact_email_id" do
      email_class.find_each do |email|
        next unless email[:corporate_site_contact_id]

        contact = contact_class.find_by(id: email[:corporate_site_contact_id])
        next unless contact

        contact.update!(corporate_site_contact_email_id: email[:id])
      end
    end

    say_with_time "Backfilling corporate_site_contact_telephone_id" do
      telephone_class.find_each do |telephone|
        next unless telephone[:corporate_site_contact_id]

        contact = contact_class.find_by(id: telephone[:corporate_site_contact_id])
        next unless contact

        contact.update!(corporate_site_contact_telephone_id: telephone[:id])
      end
    end

    remove_foreign_key :corporate_site_contact_emails, :corporate_site_contacts
    remove_index :corporate_site_contact_emails, name: "idx_on_corporate_site_contact_id_885e7bccdf"
    remove_column :corporate_site_contact_emails, :corporate_site_contact_id, :uuid

    remove_foreign_key :corporate_site_contact_telephones, :corporate_site_contacts
    remove_index :corporate_site_contact_telephones, name: "idx_on_corporate_site_contact_id_72d0fd0e7a"
    remove_column :corporate_site_contact_telephones, :corporate_site_contact_id, :uuid
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore corporate_site_contact_id once removed."
  end
end
