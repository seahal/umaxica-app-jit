# frozen_string_literal: true

class CreateAdmins < ActiveRecord::Migration[8.2]
  def change
    create_table :admins, id: :uuid do |t|
      t.string :public_id
      t.string :moniker

      t.timestamps
    end
    add_index :admins, :public_id, unique: true
  end
end
