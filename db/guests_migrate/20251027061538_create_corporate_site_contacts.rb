class CreateCorporateSiteContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contacts, id: :uuid do |t|
      t.string :category, null: false, index: true, default: 'DEFAULT_VALUE'
      t.string :status, null: false, index: true, default: 'DEFAULT_VALUE'
      t.string :token, null: false, index: true, default: '', limit: 32
      t.string      :token_digest, limit: 255
      t.timestamptz :token_expires_at
      t.boolean     :token_viewed, default: false, null: false
      t.string :contact_category_title, limit: 255
      t.string :contact_status_title, limit: 255
      t.timestamps
    end

    add_index :corporate_site_contacts, :token_digest
    add_index :corporate_site_contacts, :token_expires_at

    # 外部キー制約を追加
    add_foreign_key :corporate_site_contacts, :contact_categories,
                    column: :contact_category_title,
                    primary_key: :title
    add_foreign_key :corporate_site_contacts, :contact_statuses,
                    column: :contact_status_title,
                    primary_key: :title
  end
end
