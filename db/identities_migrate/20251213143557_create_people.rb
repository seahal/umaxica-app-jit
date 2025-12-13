class CreatePeople < ActiveRecord::Migration[8.2]
  def change
    create_table :people, id: :uuid do |t|
      t.text :body
      t.references :personality, polymorphic: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
