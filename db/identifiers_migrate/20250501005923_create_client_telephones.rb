class CreateClientTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :client_telephones, id: :binary do |t|
      t.string :number

      t.timestamps
    end
  end
end
