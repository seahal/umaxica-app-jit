# frozen_string_literal: true

class FixVerificationForeignKeyCascades < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      fix_fk(:user_verifications, :user_tokens, :user_token_id)
      fix_fk(:staff_verifications, :staff_tokens, :staff_token_id)
    end
  end

  def down
    safety_assured do
      rollback_fk(:user_verifications, :user_tokens, :user_token_id)
      rollback_fk(:staff_verifications, :staff_tokens, :staff_token_id)
    end
  end

  private

  def fix_fk(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    remove_foreign_key from_table, column: column if foreign_key_exists?(from_table, column: column)
    add_foreign_key from_table, to_table, column: column, on_delete: :cascade
  end

  def rollback_fk(from_table, to_table, column)
    return unless table_exists?(from_table) && table_exists?(to_table)
    return unless column_exists?(from_table, column)

    remove_foreign_key from_table, column: column if foreign_key_exists?(from_table, column: column)
    add_foreign_key from_table, to_table, column: column
  end
end
