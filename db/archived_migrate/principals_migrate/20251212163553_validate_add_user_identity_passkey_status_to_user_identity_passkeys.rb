# frozen_string_literal: true

class ValidateAddUserIdentityPasskeyStatusToUserIdentityPasskeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_identity_passkeys, :user_identity_passkey_statuses)
  end
end
