class CreateStaffSiteContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_site_contacts, id: :uuid do |t|
      t.string :email_address
      t.string :telephone_number
      t.string :title
      t.text :description
      t.cidr :ip_address

      t.timestamps
    end
  end
end
