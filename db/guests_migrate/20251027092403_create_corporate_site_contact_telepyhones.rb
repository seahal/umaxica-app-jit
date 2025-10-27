class CreateCorporateSiteContactTelepyhones < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contact_telepyhones, id: :uuid do |t|
      t.references :corporate_site_contact, null: false, foreign_key: true, type: :uuid
      t.string :telephone_number, null: false, default: "", limit: 1000
      t.boolean :activated, null: false, default: false
      t.boolean :deletable, null: false, default: false
      t.integer :remaining_views, null: false, default: 10, limit: 1
      t.timestamptz :expires_at, null: false, default: 1.day.from_now
      t.timestamps
    end
  end
end
