# frozen_string_literal: true

class AddRefreshFieldsToTokens < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      change_table(:user_tokens, bulk: true) do |t|
        t.string(:refresh_token_id)
        t.datetime(:refresh_token_expires_at)
        t.index(:refresh_token_id)
      end
    end

    safety_assured do
      change_table(:staff_tokens, bulk: true) do |t|
        t.string(:refresh_token_id)
        t.datetime(:refresh_token_expires_at)
        t.index(:refresh_token_id)
      end
    end
  end
end
