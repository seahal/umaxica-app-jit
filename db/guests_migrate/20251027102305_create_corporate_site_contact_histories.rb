class CreateCorporateSiteContactHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contact_histories, id: :uuid do |t|
      t.references :corporate_site_contact, null: false, foreign_key: true, type: :uuid
      t.uuid :parent_id, null: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end