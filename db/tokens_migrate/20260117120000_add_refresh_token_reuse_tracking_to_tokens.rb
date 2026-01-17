# frozen_string_literal: true

class AddRefreshTokenReuseTrackingToTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :user_tokens, :refresh_token_family_id, :string
    add_column :user_tokens, :refresh_token_generation, :integer, default: 0, null: false
    add_column :user_tokens, :compromised_at, :datetime
    add_index :user_tokens, :refresh_token_family_id, algorithm: :concurrently
    add_index :user_tokens, :compromised_at, algorithm: :concurrently

    add_column :staff_tokens, :refresh_token_family_id, :string
    add_column :staff_tokens, :refresh_token_generation, :integer, default: 0, null: false
    add_column :staff_tokens, :compromised_at, :datetime
    add_index :staff_tokens, :refresh_token_family_id, algorithm: :concurrently
    add_index :staff_tokens, :compromised_at, algorithm: :concurrently

    reversible do |dir|
      dir.up do
        safety_assured do
          execute <<~SQL.squish
            UPDATE user_tokens
            SET refresh_token_family_id = gen_random_uuid()
            WHERE refresh_token_family_id IS NULL;
          SQL
        end

        safety_assured do
          execute <<~SQL.squish
            UPDATE staff_tokens
            SET refresh_token_family_id = gen_random_uuid()
            WHERE refresh_token_family_id IS NULL;
          SQL
        end
      end
    end
  end
end
