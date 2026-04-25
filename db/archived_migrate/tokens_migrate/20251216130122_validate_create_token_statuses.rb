# frozen_string_literal: true

class ValidateCreateTokenStatuses < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_tokens, :user_token_statuses)
    validate_foreign_key(:staff_tokens, :staff_token_statuses)
  end
end
