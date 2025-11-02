class AddCorporateSiteContactReferencesToContactEmails < ActiveRecord::Migration[8.1]
  def change
    add_reference :corporate_site_contact_emails, :corporate_site_contact, type: :uuid, foreign_key: true
    add_reference :corporate_site_contact_telephones, :corporate_site_contact, type: :uuid, foreign_key: true
  end
end
