# frozen_string_literal: true

class CreateUserClientRevocations < ActiveRecord::Migration[8.2]
  def change
    create_table :user_client_revocations, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :client, null: false, foreign_key: true, type: :uuid

      t.timestamps

      t.index %i(user_id client_id), unique: true
    end
  end
end
