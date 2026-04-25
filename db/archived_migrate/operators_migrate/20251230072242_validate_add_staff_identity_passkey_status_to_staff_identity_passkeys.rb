# frozen_string_literal: true

class ValidateAddStaffIdentityPasskeyStatusToStaffIdentityPasskeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:staff_identity_passkeys, :staff_identity_passkey_statuses)
  end
end
