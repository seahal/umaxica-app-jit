class CreateCorporateSiteContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contacts, id: :uuid do |t|
      t.string :category, null: false, index: true, default: 'DEFAULT_VALUE'
      t.string :status, null: false, index: true, default: 'DEFAULT_VALUE'
      t.timestamps
    end
  end
end
