class CreatePersonas < ActiveRecord::Migration[8.0]
  def change
    create_table :personas, id: :binary do |t|
      t.string :name
      t.binary :identifier_id
      t.jsonb :avatar

      t.timestamps
    end
  end
end
