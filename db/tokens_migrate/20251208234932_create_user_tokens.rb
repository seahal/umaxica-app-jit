# frozen_string_literal: true

class CreateUserTokens < ActiveRecord::Migration[8.2]
  def change
    create_table :user_tokens, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.timestamps
    end
  end
end
