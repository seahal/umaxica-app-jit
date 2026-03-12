# typed: false
# frozen_string_literal: true

class CreateSolidCableMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :solid_cable_messages do |t|
      t.binary :channel, null: false, limit: 1024
      t.binary :payload, null: false, limit: 512.megabytes
      t.datetime :created_at, null: false
      t.integer :channel_hash, null: false, limit: 8

      t.index :channel
      t.index :channel_hash
      t.index :created_at
    end
  end
end
