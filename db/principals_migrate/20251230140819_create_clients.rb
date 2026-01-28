# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[8.2]
  def change
    create_table :clients, id: :uuid do |t|
      t.string :public_id
      t.string :moniker

      t.timestamps
    end
    add_index :clients, :public_id, unique: true
  end
end
