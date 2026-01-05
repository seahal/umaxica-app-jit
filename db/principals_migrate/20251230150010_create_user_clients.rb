# frozen_string_literal: true

class CreateUserClients < ActiveRecord::Migration[8.2]
  def change
    create_table :user_clients, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :client_id, null: false

      t.timestamps
    end

    add_index :user_clients, [:user_id, :client_id], unique: true
    add_index :user_clients, :user_id
    add_index :user_clients, :client_id

    add_foreign_key :user_clients, :users, on_delete: :cascade, validate: false
    add_foreign_key :user_clients, :clients, on_delete: :cascade, validate: false
  end
end
