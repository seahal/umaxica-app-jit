class CreateUserTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :user_telephones, id: :uuid do |t|
      t.string :number

      t.timestamps
    end
  end
end
