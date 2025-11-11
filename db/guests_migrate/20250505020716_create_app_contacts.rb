class CreateAppContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :app_contacts, id: :uuid do |t|
      t.string :public_id, null: false, index: true, limit: 21
      t.string :token, null: false, index: true, default: '', limit: 32
      t.string      :token_digest, limit: 255
      t.timestamptz :token_expires_at
      t.boolean     :token_viewed, default: false, null: false
      t.inet :ip_address
      t.string :contact_category_title, limit: 255
      t.string :contact_status_title, limit: 255
      t.timestamps
    end

    add_index :app_contacts, :token_digest
    add_index :app_contacts, :token_expires_at

    # 外部キー制約を追加
    add_foreign_key :app_contacts, :app_contact_categories,
                    column: :contact_category_title,
                    primary_key: :title
    add_foreign_key :app_contacts, :app_contact_statuses,
                    column: :contact_status_title,
                    primary_key: :title
  end
end
