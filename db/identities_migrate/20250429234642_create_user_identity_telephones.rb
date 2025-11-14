class CreateUserIdentityTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identity_telephones, id: :uuid do |t|
      t.references :user
      t.string :number

      t.timestamps
    end
  end
end
