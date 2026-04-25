# frozen_string_literal: true

class AddTokenKindToUserTokens < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_column(:user_tokens, :user_token_kind_id, :string, null: false, default: "BROWSER_WEB")
      add_index(:user_tokens, :user_token_kind_id)
      add_foreign_key(:user_tokens, :user_token_kinds)
    end
  end
end
