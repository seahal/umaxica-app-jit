class CreateServiceSiteContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :service_site_contacts, id: :uuid do |t|
      t.string :email_address
      t.string :telephone_number
      t.string :title
      t.text :description
      t.cidr :ip_address
      t.string :contact_category_title, limit: 255
      t.string :contact_status_title, limit: 255
      t.timestamps
    end

    # ここに add_foreign_key を移動
    add_foreign_key :service_site_contacts, :contact_categories,
                    column: :contact_category_title,
                    primary_key: :title
    add_foreign_key :service_site_contacts, :contact_statuses,  # ← typo修正: service_site_statuses → service_site_contacts
                    column: :contact_status_title,
                    primary_key: :title
  end
end