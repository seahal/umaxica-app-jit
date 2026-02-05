# frozen_string_literal: true

class CreateComContactHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :com_contact_histories do |t|
      t.references :com_contact, null: false, foreign_key: true, type: :bigint
      t.bigint :parent_id, null: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
