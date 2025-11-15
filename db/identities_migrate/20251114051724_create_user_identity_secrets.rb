class CreateUserIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    create_table :user_identity_secrets, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :password_digest
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
