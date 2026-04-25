# frozen_string_literal: true

class ValidateAddUserIdentityGoogleAuthStatusToUserGoogleAuths < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(:user_google_auths, :user_identity_google_auth_statuses)
  end
end
