# frozen_string_literal: true

class AddTokenKindToStaffTokens < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_column :staff_tokens, :staff_token_kind_id, :string, null: false, default: "BROWSER_WEB"
      add_index :staff_tokens, :staff_token_kind_id
      add_foreign_key :staff_tokens, :staff_token_kinds
    end
  end
end
