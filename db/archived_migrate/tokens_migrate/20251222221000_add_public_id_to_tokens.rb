# frozen_string_literal: true

class AddPublicIdToTokens < ActiveRecord::Migration[8.2]
  def up
    add_column(:user_tokens, :public_id, :string, limit: 21)
    add_column(:staff_tokens, :public_id, :string, limit: 21)

    update_public_ids(:user_tokens)
    update_public_ids(:staff_tokens)

    safety_assured { change_column_null(:user_tokens, :public_id, false) }
    safety_assured { change_column_null(:staff_tokens, :public_id, false) }

    safety_assured { add_index(:user_tokens, :public_id, unique: true) }
    safety_assured { add_index(:staff_tokens, :public_id, unique: true) }

    safety_assured { add_check_constraint(:user_tokens, "char_length(public_id) = 21", name: "chk_user_tokens_public_id_length", validate: false) }
    safety_assured { add_check_constraint(:staff_tokens, "char_length(public_id) = 21", name: "chk_staff_tokens_public_id_length", validate: false) }

    safety_assured { add_check_constraint(:user_tokens, "public_id ~ '^[A-Za-z0-9_-]{21}$'", name: "chk_user_tokens_public_id_format", validate: false) }
    safety_assured { add_check_constraint(:staff_tokens, "public_id ~ '^[A-Za-z0-9_-]{21}$'", name: "chk_staff_tokens_public_id_format", validate: false) }
  end

  def down
    remove_column(:staff_tokens, :public_id)
    remove_column(:user_tokens, :public_id)
  end

  private

  def update_public_ids(table)
    safety_assured do
    end
  end
end
