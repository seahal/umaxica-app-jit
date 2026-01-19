# frozen_string_literal: true

class CreateUserTokenKinds < ActiveRecord::Migration[8.2]
  def up
    create_table :user_token_kinds, id: false do |t|
      t.string :id, primary_key: true
    end
  end

  def down
    drop_table :user_token_kinds
  end
end
