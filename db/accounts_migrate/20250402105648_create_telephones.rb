class CreateTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :telephones, id: :bytea do |t|
      t.string :number
      t.string :entryable_type
      t.binary :entryable_id
      t.timestamps
    end
  end
end
