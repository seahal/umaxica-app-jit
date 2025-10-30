class CreateStaffSiteContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_site_contacts, id: :uuid do |t|
      t.string :email_address
      t.string :telephone_number
      t.string :title
      t.text :description
      t.cidr :ip_address
      t.string :contact_category_title, limit: 255
      t.string :contact_status_title, limit: 255
      t.timestamps
    end
    # 外部キー制約を追加
    add_foreign_key :staff_site_contacts, :contact_categories,
                    column: :contact_category_title,
                    primary_key: :title
    add_foreign_key :staff_site_contacts, :contact_statuses,
                    column: :contact_status_title,
                    primary_key: :title
  end
end
