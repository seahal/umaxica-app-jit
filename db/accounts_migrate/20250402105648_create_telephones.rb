class CreateTelephones < ActiveRecord::Migration[8.0]
  def change
    create_table :telephones, id: :bytea do |t|
      t.string :number
      t.binary :universal_telephone_identifiers_id
      t.timestamps
    end
  end
end
