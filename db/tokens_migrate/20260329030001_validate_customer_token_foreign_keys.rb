# frozen_string_literal: true

class ValidateCustomerTokenForeignKeys < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    validate_foreign_key(:customer_tokens, :customer_token_binding_methods, name: "fk_customer_tokens_on_customer_token_binding_method_id")
    validate_foreign_key(:customer_tokens, :customer_token_dbsc_statuses, name: "fk_customer_tokens_on_customer_token_dbsc_status_id")
    validate_foreign_key(:customer_tokens, :customer_token_kinds, name: "fk_customer_tokens_on_customer_token_kind_id")
    validate_foreign_key(:customer_tokens, :customer_token_statuses, name: "fk_customer_tokens_on_customer_token_status_id")
  end
end
