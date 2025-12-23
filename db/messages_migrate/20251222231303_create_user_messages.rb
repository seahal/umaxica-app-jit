class CreateUserMessages < ActiveRecord::Migration[8.2]
  def change
    create_table :user_messages, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :user_id
      t.uuid :public_id

      t.timestamps
    end
  end
end
