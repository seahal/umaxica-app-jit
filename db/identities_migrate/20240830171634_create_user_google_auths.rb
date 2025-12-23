class CreateUserGoogleAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :user_google_auths, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.string :token
      t.timestamps
    end
  end
end
