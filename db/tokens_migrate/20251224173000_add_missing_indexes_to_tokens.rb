class AddMissingIndexesToTokens < ActiveRecord::Migration[8.2]
  def change
    add_index :staff_tokens, :staff_id
    add_index :staff_tokens, :staff_token_status_id
    add_index :user_tokens, :user_id
    add_index :user_tokens, :user_token_status_id
  end
end
