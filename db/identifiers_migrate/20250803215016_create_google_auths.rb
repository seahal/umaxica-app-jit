class CreateGoogleAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :google_auths, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider
      t.string :uid
      t.string :email
      t.string :name
      t.string :image_url
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.text :raw_info

      t.timestamps
    end
  end
end
