# frozen_string_literal: true

class AddRefreshTokenDigestToTokens < ActiveRecord::Migration[8.2]
  def up
    add_column(:user_tokens, :refresh_token_digest, :string)
    add_column(:staff_tokens, :refresh_token_digest, :string)

    safety_assured { change_column_null(:user_tokens, :refresh_token_digest, false) }
    safety_assured { change_column_null(:staff_tokens, :refresh_token_digest, false) }

    safety_assured { add_index(:user_tokens, :refresh_token_digest, unique: true) }
    safety_assured { add_index(:staff_tokens, :refresh_token_digest, unique: true) }
  end

  def down
    remove_index(:staff_tokens, :refresh_token_digest)
    remove_index(:user_tokens, :refresh_token_digest)

    remove_column(:staff_tokens, :refresh_token_digest)
    remove_column(:user_tokens, :refresh_token_digest)
  end
end
