# frozen_string_literal: true

class CreateUserTokens < ActiveRecord::Migration[7.2]
    def change
      create_table :user_tokens, id: :uuid do |t|
        t.uuid :user_id

        t.timestamps
      end
    end
end
