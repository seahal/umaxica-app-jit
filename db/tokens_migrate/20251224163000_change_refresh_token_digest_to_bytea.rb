# frozen_string_literal: true

class ChangeRefreshTokenDigestToBytea < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :user_tokens, :refresh_token_digest, :binary,
                      using: "convert_to(refresh_token_digest, 'UTF8')"
        change_column :staff_tokens, :refresh_token_digest, :binary,
                      using: "convert_to(refresh_token_digest, 'UTF8')"
      end

      dir.down do
        change_column :user_tokens, :refresh_token_digest, :string,
                      using: "convert_from(refresh_token_digest, 'UTF8')"
        change_column :staff_tokens, :refresh_token_digest, :string,
                      using: "convert_from(refresh_token_digest, 'UTF8')"
      end
    end

    reversible do |dir|
      dir.up do
        add_index :user_tokens, :refresh_token_digest,
                  unique: true,
                  name: "index_user_tokens_on_refresh_token_digest"
        add_index :staff_tokens, :refresh_token_digest,
                  unique: true,
                  name: "index_staff_tokens_on_refresh_token_digest"
      end

      dir.down do
        remove_index :user_tokens, name: "index_user_tokens_on_refresh_token_digest"
        remove_index :staff_tokens, name: "index_staff_tokens_on_refresh_token_digest"
      end
    end
  end
end
