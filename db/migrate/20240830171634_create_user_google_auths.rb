class CreateUserGoogleAuths < ActiveRecord::Migration[7.2]
  def change
    create_table :user_google_auths, id: :uuid do |t|
      t.string :token
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
