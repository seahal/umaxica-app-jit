class CreateStaffTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_telephones, id: :binary  do |t|
      t.string :number

      t.timestamps
    end
  end
end
