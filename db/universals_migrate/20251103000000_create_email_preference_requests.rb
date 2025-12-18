class CreateEmailPreferenceRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :email_preference_requests, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :email_address, limit: 1000, null: false
      t.string :context, limit: 32, null: false
      t.string :token_digest, limit: 64, null: false
      t.jsonb :preferences, null: false, default: {}
      t.datetime :token_expires_at, null: false
      t.datetime :token_used_at
      t.datetime :sent_at
      t.timestamps
    end

    add_index :email_preference_requests, :context
    add_index :email_preference_requests, :token_digest, unique: true
  end
end
