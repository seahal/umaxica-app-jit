# frozen_string_literal: true

class CreateOrgContactTopics < ActiveRecord::Migration[8.2]
  def change
    create_table :org_contact_topics, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :org_contact, null: false, foreign_key: true, type: :uuid
      t.boolean :activated, null: false, default: false
      t.boolean :deletable, null: false, default: false
      t.integer :remaining_views, null: false, default: 10, limit: 1
      t.string :otp_digest, limit: 255
      t.timestamptz :otp_expires_at
      t.integer :otp_attempts_left, limit: 2, default: 3, null: false
      t.timestamptz :expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" }
      t.timestamps
    end
  end
end
