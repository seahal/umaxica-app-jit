# frozen_string_literal: true

class CreateComPreferences < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preferences do |t|
      t.string :public_id
      t.datetime :expires_at
      t.binary :token_digest

      t.timestamps
    end
  end
end
