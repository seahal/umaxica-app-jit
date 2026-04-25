# frozen_string_literal: true

class ValidateCreateUserIdentityOneTimePasswordStatuses < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key(
      :user_identity_one_time_passwords, :user_identity_one_time_password_statuses,
    )
  end
end
