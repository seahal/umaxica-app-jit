class CreateRoles < ActiveRecord::Migration[8.2]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :key
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
