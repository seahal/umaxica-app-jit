# frozen_string_literal: true

class ValidateCreateStaffIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:staff_identity_secrets, :staff_identity_secret_statuses)
  end
end
