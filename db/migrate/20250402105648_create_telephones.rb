class CreateTelephones < ActiveRecord::Migration[8.1]
  def change
    create_table :telephones do |t|
      t.string :number

      t.timestamps
    end
  end
end
