class CreateStaffIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_identity_secrets, id: :uuid do |t|
      t.references :staff, null: false, foreign_key: true, type: :uuid
      t.string :password_digest
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
