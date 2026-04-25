# frozen_string_literal: true

class ValidateAddUserIdentitySecretStatusToUserIdentitySecrets < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_identity_secrets, :user_identity_secret_statuses)
  end
end
