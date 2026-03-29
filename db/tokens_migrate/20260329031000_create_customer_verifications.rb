# frozen_string_literal: true

class CreateCustomerVerifications < ActiveRecord::Migration[8.2]
  def change
    create_table(:customer_verifications, id: :bigserial) do |t|
      t.references(:customer_token, null: false, foreign_key: true, type: :bigserial, index: false)
      t.string(:token_digest, null: false)
      t.datetime(:expires_at, null: false)
      t.datetime(:revoked_at)
      t.datetime(:last_used_at)

      t.timestamps
    end

    add_index(:customer_verifications, :customer_token_id)
    add_index(:customer_verifications, :expires_at)
    add_index(:customer_verifications, :token_digest, unique: true)
  end
end
