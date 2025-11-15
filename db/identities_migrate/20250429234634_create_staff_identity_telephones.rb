class CreateStaffIdentityTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_identity_telephones, id: :uuid do |t|
      t.references :staff
      t.string :number

      t.timestamps
    end
  end
end
