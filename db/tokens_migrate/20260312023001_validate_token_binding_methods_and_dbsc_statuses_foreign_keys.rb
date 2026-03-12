# frozen_string_literal: true

class ValidateTokenBindingMethodsAndDbscStatusesForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :user_tokens, :user_token_binding_methods, name: "fk_user_tokens_on_user_token_binding_method_id"
    validate_foreign_key :user_tokens, :user_token_dbsc_statuses, name: "fk_user_tokens_on_user_token_dbsc_status_id"
    validate_foreign_key :staff_tokens, :staff_token_binding_methods, name: "fk_staff_tokens_on_staff_token_binding_method_id"
    validate_foreign_key :staff_tokens, :staff_token_dbsc_statuses, name: "fk_staff_tokens_on_staff_token_dbsc_status_id"
  end
end
