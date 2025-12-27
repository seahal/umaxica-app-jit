# frozen_string_literal: true

class CreateUserOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :user_occurrences, id: :uuid do |t|
      t.string :public_id, limit: 21
      t.string :body, limit: 36
      t.string :status_id, limit: 255
      t.string :memo, limit: 1024

      t.timestamps
    end
  end
end
