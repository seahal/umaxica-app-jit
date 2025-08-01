# frozen_string_literal: true

class CreateUserGoogleAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :user_google_auths, id: :uuid do |t|
      t.timestamps
    end
  end
end
