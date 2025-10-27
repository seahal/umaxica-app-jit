class CreateCorporateSiteContactTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contact_topics, id: :uuid do |t|
      t.references :corporate_site_contact, null: false, foreign_key: true, type: :uuid
      t.boolean :activated, null: false, default: false
      t.boolean :deletable, null: false, default: false
      t.integer :remaining_views, null: false, default: 10, limit: 1
      t.string :otp_digest, limit: 255
      t.timestamptz :otp_expires_at
      t.integer :otp_attempts_left, limit: 2, default: 3, null: false
      t.timestamptz :expires_at, null: false, default: 1.day.from_now
      t.timestamps
    end
  end
end
