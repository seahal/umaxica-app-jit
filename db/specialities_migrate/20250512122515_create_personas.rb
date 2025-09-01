class CreatePersonas < ActiveRecord::Migration[8.0]
  def change
    create_table :personas, id: :uuid do |t|
      t.string :name
      t.uuid :identifier_id
      t.jsonb :avatar

      t.timestamps
    end
  end
end
