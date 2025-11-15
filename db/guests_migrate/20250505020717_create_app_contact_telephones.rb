class CreateAppContactTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :app_contact_telephones, id: :string do |t|
      t.references :app_contact, null: false, foreign_key: true, type: :uuid, index: true
      t.string :telephone_number, null: false, default: "", limit: 1000
      t.boolean :activated, null: false, default: false
      t.boolean :deletable, null: false, default: false
      t.integer :remaining_views, null: false, default: 10, limit: 1
      t.string :verifier_digest, limit: 255
      t.timestamptz :verifier_expires_at
      t.integer :verifier_attempts_left, limit: 2, default: 3, null: false
      t.timestamptz :expires_at, null: false, default: 1.day.from_now
      t.timestamps
    end

    add_index :app_contact_telephones, :verifier_expires_at
    add_index :app_contact_telephones, :telephone_number
  end
end
