# typed: false
# frozen_string_literal: true

class CreateUserAuthorizationCodes < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:users)
    return if table_exists?(:user_authorization_codes)

    create_table(:user_authorization_codes) do |t|
      t.string(:code, limit: 64, null: false)
      t.references(:user, null: false, foreign_key: true, type: :bigint)
      t.string(:client_id, limit: 64, null: false)
      t.text(:redirect_uri, null: false)
      t.string(:code_challenge, null: false)
      t.string(:code_challenge_method, limit: 8, null: false, default: "S256")
      t.string(:scope)
      t.string(:state)
      t.string(:nonce)
      t.string(:auth_method, null: false, default: "")
      t.string(:acr, null: false, default: "aal1")
      t.datetime(:varnishable_at, null: false)
      t.datetime(:consumed_at)
      t.datetime(:revoked_at)

      t.timestamps
    end

    add_index(:user_authorization_codes, :code, unique: true)
    add_index(:user_authorization_codes, :varnishable_at)
  end
end
