class CreateCorporateSiteContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contacts, id: :uuid do |t|
      t.string :category, null: false, index: true, default: 'DEFAULT_VALUE'
      t.string :status, null: false, index: true, default: 'DEFAULT_VALUE'
      t.string :token, null: false, index: true, default: '', limit: 32
      t.string      :token_digest, limit: 255
      t.timestamptz :token_expires_at
      t.boolean     :token_viewed, default: false, null: false
      t.timestamps
    end

    add_index :corporate_site_contacts, :token_digest
    add_index :corporate_site_contacts, :token_expires_at
  end
end
