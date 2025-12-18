class CreateUserTokens < ActiveRecord::Migration[8.2]
  def change
    create_table :user_tokens, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :user_id, null: false
      t.timestamps
    end
  end
end
