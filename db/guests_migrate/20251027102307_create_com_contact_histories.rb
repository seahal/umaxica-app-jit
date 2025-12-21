class CreateComContactHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :com_contact_histories, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :com_contact, null: false, foreign_key: true, type: :uuid
      t.uuid :parent_id, null: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
