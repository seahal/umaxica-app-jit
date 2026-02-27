# frozen_string_literal: true

class AddPublicIdToTokens < ActiveRecord::Migration[8.2]
  def up
    add_column :user_tokens, :public_id, :string, limit: 21
    add_column :staff_tokens, :public_id, :string, limit: 21

    update_public_ids(:user_tokens)
    update_public_ids(:staff_tokens)

    change_column_null :user_tokens, :public_id, false
    change_column_null :staff_tokens, :public_id, false

    add_index :user_tokens, :public_id, unique: true
    add_index :staff_tokens, :public_id, unique: true
  end

  def down
    remove_index :user_tokens, :public_id
    remove_index :staff_tokens, :public_id
    remove_column :user_tokens, :public_id
    remove_column :staff_tokens, :public_id
  end

  private

  def update_public_ids(table)
    execute <<~SQL.squish
      UPDATE #{table}
      SET public_id = substring(
        regexp_replace(
          translate(encode(gen_random_bytes(32), 'base64'), '+/', '-_'),
          '=', '',
          'g'
        ),
        1,
        21
      )
      WHERE public_id IS NULL
    SQL
  end
end
