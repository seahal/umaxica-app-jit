# frozen_string_literal: true

class CreateUserAppleAuths < ActiveRecord::Migration[7.2]
    def change
      create_table :user_apple_auths, id: :uuid do |t|
        t.string :token
        t.references :user
        t.timestamps
      end
    end
end
