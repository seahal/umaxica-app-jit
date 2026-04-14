# typed: false
# frozen_string_literal: true

class AddCustomerIdToAuthorizationCodes < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    add_column(:authorization_codes, :customer_id, :bigint, null: true) unless column_exists?(
      :authorization_codes,
      :customer_id,
    )
    add_index(:authorization_codes, :customer_id, algorithm: :concurrently) unless index_exists?(
      :authorization_codes,
      :customer_id,
    )

    remove_check_constraint(:authorization_codes, name: "chk_authorization_codes_resource") if check_constraint_exists?(
      :authorization_codes,
      name: "chk_authorization_codes_resource",
    )

    add_check_constraint(
      :authorization_codes,
      "(user_id IS NOT NULL AND staff_id IS NULL AND customer_id IS NULL) OR " \
      "(user_id IS NULL AND staff_id IS NOT NULL AND customer_id IS NULL) OR " \
      "(user_id IS NULL AND staff_id IS NULL AND customer_id IS NOT NULL)",
      name: "chk_authorization_codes_resource",
      validate: false,
    )
    validate_check_constraint(:authorization_codes, name: "chk_authorization_codes_resource")
  end

  def down
    remove_check_constraint(:authorization_codes, name: "chk_authorization_codes_resource") if check_constraint_exists?(
      :authorization_codes,
      name: "chk_authorization_codes_resource",
    )

    remove_index(:authorization_codes, :customer_id) if index_exists?(:authorization_codes, :customer_id)
    remove_column(:authorization_codes, :customer_id) if column_exists?(:authorization_codes, :customer_id)
  end
end
