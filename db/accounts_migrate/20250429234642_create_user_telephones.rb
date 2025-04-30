class CreateUserTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :user_telephones do |t|
      t.string :number

      t.timestamps
    end
  end
end
