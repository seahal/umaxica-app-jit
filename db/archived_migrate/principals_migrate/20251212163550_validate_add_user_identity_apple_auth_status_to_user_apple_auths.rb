# frozen_string_literal: true

class ValidateAddUserIdentityAppleAuthStatusToUserAppleAuths < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_apple_auths, :user_identity_apple_auth_statuses)
  end
end
