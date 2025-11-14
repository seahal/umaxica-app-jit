class CreateStaffIdentityPasskeys < ActiveRecord::Migration[8.0]
  def change
    # create_table :user_identity_passkeys, id: :uuid do |t|
    #   t.references :user, null: false, foreign_key: true
    #   t.uuid :webauthn_id, null: false
    #   t.text :public_key, null: false
    #   t.string :description, null: false
    #   t.bigint :sign_count, null: false, default: 0
    #   t.uuid :external_id, null: false
    #   t.timestamps
    # end
  end
end
