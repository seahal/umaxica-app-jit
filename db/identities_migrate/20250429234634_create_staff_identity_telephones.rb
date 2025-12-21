class CreateStaffIdentityTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_identity_telephones, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :staff, type: :uuid, foreign_key: true
      t.string :number

      t.timestamps
    end
  end
end
