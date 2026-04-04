# frozen_string_literal: true

class CreateCustomerPasskeys < ActiveRecord::Migration[8.2]
  def change
    create_table(:customer_passkeys, if_not_exists: true) do |t|
      t.bigint(:customer_id, null: false)
      t.uuid(:external_id, null: false)
      t.string(:public_id, null: false, limit: 21)
      t.string(:webauthn_id, null: false, default: "")
      t.text(:public_key, null: false)
      t.bigint(:sign_count, null: false, default: 0)
      t.string(:description, null: false, default: "")
      t.bigint(:status_id, null: false, default: 1)
      t.datetime(:last_used_at)

      t.timestamps
    end

    add_foreign_key(
      :customer_passkeys,
      :customers,
      column: :customer_id,
      on_delete: :restrict,
      if_not_exists: true,
      validate: false
    )

    add_index(:customer_passkeys, :public_id, unique: true, if_not_exists: true)
    add_index(:customer_passkeys, :webauthn_id, unique: true, if_not_exists: true)
    add_index(:customer_passkeys, :status_id, if_not_exists: true)
    add_index(:customer_passkeys, :customer_id, if_not_exists: true)

    add_foreign_key(
      :customer_passkeys,
      :customer_passkey_statuses,
      column: :status_id,
      on_delete: :restrict,
      if_not_exists: true,
      validate: false
    )
  end
end
